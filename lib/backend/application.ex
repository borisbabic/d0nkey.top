defmodule Backend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  require Logger
  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children =
      [
        # Start the Ecto repository
        Backend.Repo,
        # Start the endpoint when the application starts
        {Phoenix.PubSub, name: Backend.PubSub},
        Backend.Telemetry,
        BackendWeb.Presence,
        BackendWeb.Endpoint,
        # Starts a worker by calling: Backend.Worker.start_link(arg)
        # {Backend.Worker, arg},
        {Oban, oban_config()},
        # Backend.PostgrexPubsubListener,
        %{
          # can  multiserver
          id: Hearthstone.DeckTracker.GameInsertBatcher,
          start: {Hearthstone.DeckTracker.GameInsertBatcher, :start_link, [[]]}
        },
        %{
          # can  multiserver, prolly
          id: Backend.Infrastructure.ApiCache,
          start: {Backend.Infrastructure.ApiCache, :start_link, [[]]}
        },
        %{
          # can  multiserver, prolly
          id: Backend.Infrastructure.PlayerStatsCache,
          start: {Backend.Infrastructure.PlayerStatsCache, :start_link, [[]]}
        },
        %{
          # can multiserver, I think
          id: Twitch.TokenRefresher,
          start: {Twitch.TokenRefresher, :start_link, [[]]}
        },
        %{
          # can  multiserver
          id: Twitch.HearthstoneLive,
          start: {Twitch.HearthstoneLive, :start_link, [[]]}
        },
        # %{
        #   id: Backend.HSReplay.StreamingNow,
        #   start: {Backend.HSReplay.StreamingNow, :start_link, [[]]}
        # },
        %{
          # can multiserver
          id: Backend.Streaming.StreamingNow,
          start: {Backend.Streaming.StreamingNow, :start_link, [[]]}
        },
        %{
          # might have acceptable issues multiservering
          id: Backend.Infrastructure.PlayerNationalityCache,
          start: {Backend.Infrastructure.PlayerNationalityCache, :start_link, [[]]}
        },
        %{
          # multiserverable, might get out of sync if multiple?
          id: Backend.HearthstoneJson,
          start: {Backend.HearthstoneJson, :start_link, [[fetch_fresh: fetch_fresh?()]]}
        },
        %{
          # might have acceptable issues multiservering
          id: Backend.StreamerTwitchInfoUpdater,
          start: {Backend.StreamerTwitchInfoUpdater, :start_link, [[]]}
        },
        %{
          # sync issues multiserviering? might be fine
          id: Backend.PrioritizedBattletagCache,
          start: {Backend.PrioritizedBattletagCache, :start_link, [[]]}
        },
        %{
          # can multiserver
          id: Backend.DeckInteractionTracker,
          start: {Backend.DeckInteractionTracker, :start_link, [[]]}
        },
        # %{
        #   # who cares
        #   id: Backend.GMStream,
        #   start: {Backend.GMStream, :start_link, [[]]}
        # },
        %{
          # can multi server
          id: Backend.PlayerIconBag,
          start: {Backend.PlayerIconBag, :start_link, [[]]}
        },
        %{
          # can prolly multiserver
          id: Hearthstone.Api,
          start: {Hearthstone.Api, :start_link, [[]]}
        },
        %{
          # can multiserver with acceptable potential desync issues
          id: Backend.Hearthstone.CardBag,
          start: {Backend.Hearthstone.CardBag, :start_link, [[]]}
        },
        # %{
        #   # who cares
        #   id: Backend.Grandmasters,
        #   start: {Backend.Grandmasters, :start_link, [[]]}
        # },
        %{
          # can multiserver with acceptable issues
          id: Backend.LatestHSArticles,
          start: {Backend.LatestHSArticles, :start_link, [[]]}
        },
        %{
          # can multiserver, prolly
          id: Backend.AdsTxtCache,
          start: {Backend.AdsTxtCache, :start_link, [[]]}
        },
        # %{
        #   # can multiserver, prolly, who cares
        #   id: Backend.PonyDojo,
        #   start: {Backend.PonyDojo, :start_link, [[]]}
        # },
        %{
          # can multiserver
          id: Backend.Streaming.DeckStreamingInfoBag,
          start: {Backend.Streaming.DeckStreamingInfoBag, :start_link, [[]]}
        },
        %{
          # TODO: CANNOT MULTISERVEr
          id: Backend.Streaming.StreamerDeckBag,
          start: {Backend.Streaming.StreamerDeckBag, :start_link, [[]]}
        },
        %{
          # TODO: CANNOT MULTISERVEr
          id: Backend.PlayerCountryPreferenceBag,
          start: {Backend.PlayerCountryPreferenceBag, :start_link, [[]]}
        },
        %{
          # can multiserver, prolly?
          id: Hearthstone.DeckTracker.ArchetypeBag,
          start: {Hearthstone.DeckTracker.ArchetypeBag, :start_link, [[]]}
        },
        {Task, &warmup_cache/0},
        QuantumScheduler
      ]
      |> add_twitch_bot()
      |> add_dt_insert_listener()
      |> check_bot()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Backend.Supervisor]
    start_result = Supervisor.start_link(children, opts)
    # migrate()
    # Backend.MastersTour.rename_tour_stop("Montreal", "Montréal")
    #    Backend.Hearthstone.add_class_and_regenerate_deckcode()
    start_result
  end

  def add_twitch_bot(prev) do
    case Application.fetch_env(:backend, :enable_twitch_bot) do
      {:ok, true} ->
        config = twitch_bot_config()
        Logger.debug("Twitch bot enabled")
        prev ++ [{TMI.Supervisor, config}]

      _ ->
        Logger.debug("Twitch bot disabled")
        prev
    end
  end

  def twitch_bot_config() do
    with {:ok, config} <- Application.fetch_env(:backend, :twitch_bot_config),
         {{:ok, chats}, _} <- {Application.fetch_env(:backend, :twitch_bot_chats), config} do
      config
      |> Keyword.put(:channels, chats)
      |> Keyword.put(:mod_channels, chats)
    else
      {:error, config} when is_list(config) -> config
      _ -> []
    end
  end

  def migrate() do
    with {:ok, true} <- Application.fetch_env(:backend, :auto_migrate) do
      try do
        Ecto.Migrator.run(Backend.Repo, "priv/repo/migrations", :up, all: true)
      rescue
        _ -> Logger.error("MIGRATION FAILED ON STARTUP!")
      end
    end
  end

  def fetch_fresh?(default \\ false) do
    case Application.fetch_env(:backend, :hearthstone_json_fetch_fresh) do
      {:ok, fetch_fresh} -> fetch_fresh
      _ -> default
    end
  end

  def add_dt_insert_listener(prev) do
    case Application.fetch_env(:backend, :dt_insert_listener) do
      {:ok, true} ->
        prev ++
          [
            %{
              # TODO: CANNOT MULTISERVER, prolly. NEEDS ATTENTION
              # CAN do bot separate config
              id: Hearthstone.DeckTracker.InsertListener,
              start: {Hearthstone.DeckTracker.InsertListener, :start_link, [[]]}
            }
          ]

      _ ->
        prev
    end
  end

  def check_bot(prev) do
    case Application.fetch_env(:backend, :enable_bot) do
      {:ok, true} -> prev ++ [Bot.Consumer]
      _ -> prev
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def warmup_cache() do
    with {:ok, true} <- Application.fetch_env(:backend, :warmup_cache) do
      [
        &Backend.MastersTour.warmup_stats_cache/0,
        &Backend.MastersTour.warmup_player_nationality_cache/0
      ]
      |> Enum.each(fn f ->
        try do
          f.()
        rescue
          _ -> nil
        catch
          _ -> nil
        end
      end)
    end
  end

  def oban_config() do
    Application.get_env(:backend, Oban)
  end
end
