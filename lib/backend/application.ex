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
        Backend.PostgrexPubsubListener,
        %{
          id: Backend.Infrastructure.ApiCache,
          start: {Backend.Infrastructure.ApiCache, :start_link, [[]]}
        },
        %{
          id: Backend.Infrastructure.PlayerStatsCache,
          start: {Backend.Infrastructure.PlayerStatsCache, :start_link, [[]]}
        },
        %{
          id: Twitch.TokenRefresher,
          start: {Twitch.TokenRefresher, :start_link, [[]]}
        },
        %{
          id: Twitch.HearthstoneLive,
          start: {Twitch.HearthstoneLive, :start_link, [[]]}
        },
        # %{
        #   id: Backend.HSReplay.StreamingNow,
        #   start: {Backend.HSReplay.StreamingNow, :start_link, [[]]}
        # },
        %{
          id: Backend.Streaming.StreamingNow,
          start: {Backend.Streaming.StreamingNow, :start_link, [[]]}
        },
        %{
          id: Backend.Infrastructure.PlayerNationalityCache,
          start: {Backend.Infrastructure.PlayerNationalityCache, :start_link, [[]]}
        },
        %{
          id: Backend.HearthstoneJson,
          start: {Backend.HearthstoneJson, :start_link, [[fetch_fresh: fetch_fresh()]]}
        },
        %{
          id: Backend.StreamerTwitchInfoUpdater,
          start: {Backend.StreamerTwitchInfoUpdater, :start_link, [[]]}
        },
        %{
          id: Backend.PrioritizedBattletagCache,
          start: {Backend.PrioritizedBattletagCache, :start_link, [[]]}
        },
        %{
          id: Backend.DeckInteractionTracker,
          start: {Backend.DeckInteractionTracker, :start_link, [[]]}
        },
        %{
          id: Backend.GMStream,
          start: {Backend.GMStream, :start_link, [[]]}
        },
        %{
          id: Backend.PlayerIconBag,
          start: {Backend.PlayerIconBag, :start_link, [[]]}
        },
        %{
          id: Hearthstone.DeckTracker.InsertListener,
          start: {Hearthstone.DeckTracker.InsertListener, :start_link, [[]]}
        },
        %{
          id: Hearthstone.Api,
          start: {Hearthstone.Api, :start_link, [[]]}
        },
        %{
          id: Backend.Hearthstone.CardBag,
          start: {Backend.Hearthstone.CardBag, :start_link, [[]]}
        },
        %{
          id: Backend.Grandmasters,
          start: {Backend.Grandmasters, :start_link, [[]]}
        },
        {Task, &warmup_cache/0},
        QuantumScheduler
      ]
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

  def migrate() do
    if Application.fetch_env!(:backend, :auto_migrate) do
      try do
        Ecto.Migrator.run(Backend.Repo, "priv/repo/migrations", :up, all: true)
      rescue
        _ -> Logger.error("MIGRATION FAILED ON STARTUP!")
      end
    end
  end

  def fetch_fresh(), do: Application.fetch_env!(:backend, :hearthstone_json_fetch_fresh)

  def check_bot(prev) do
    if Application.fetch_env!(:backend, :enable_bot) do
      prev ++ [Bot.Consumer]
    else
      prev
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def warmup_cache() do
    if Application.fetch_env!(:backend, :warmup_cache) do
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
