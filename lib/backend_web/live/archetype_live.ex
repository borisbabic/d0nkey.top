defmodule BackendWeb.ArchetypeLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.OpponentStatsTable
  alias Components.ReplayExplorer
  alias Backend.DeckInteractionTracker, as: Tracker
  import Backend.Hearthstone.Deck, only: [format_name: 1]

  data(archetype, :any)
  data(user, :any)
  data(stats_params, :map)
  data(replay_params, :map)

  def mount(_, session, socket) do
    {:ok, assign_defaults(socket, session) |> put_user_in_context()}
  end

  def handle_params(params = %{"archetype" => archetype}, _session, socket) do
    stats_params = params |> Map.take(OpponentStatsTable.param_keys())
    replay_params = ReplayExplorer.filter_relevant(params)
    format_name = parse_format_name(params)
    title = "#{archetype} #{format_name} stats"

    {
      :noreply,
      socket
      |> assign(
        archetype: archetype,
        stats_params: stats_params,
        replay_params: replay_params,
        title: title
      )
      |> assign_meta_tags(%{title: title})
    }
  end

  def render(assigns) do
    ~F"""
    <div class="title is-2">{@title || @archetype}</div>
    <div class="subtitle is-6">
      <span><a href={~p"/card-stats?#{card_stats_params(@archetype, @stats_params)}"}>Card Stats</a> | </span>
      <span><a href={~p"/decks?#{decks_params(@archetype, @stats_params) |> add_games_filters(@stats_params)}"}>Decks</a> </span>
    </div>
    <div id="below-title-ads">
      <FunctionComponents.Ads.below_title/>
    </div>
    <div class="columns is-multiline is-mobile is-narrow is-centered">
      <div class="column">
        <div class="subtitle is-4 has-text-centered-mobile">Stats</div>
        <OpponentStatsTable id="archetype_stats" include_format={true} target={@archetype} live_view={__MODULE__} path_params={to_string(@archetype)} params={@stats_params} />
      </div>
      <div class="column">
        <div class="subtitle is-4 has-text-centered-mobile">Replays</div>
        <ReplayExplorer
          id="archetype_replays"
          additional_params={replay_params(@archetype)}
          path_params={@archetype}
          params={@replay_params}
          show_deck={true}
          show_mode={false}
          hide_deck_mobile={true}
          show_opponent={true}
          show_played={false}
          show_opponent_name={false}
          show_result_as={[:rank]}
          format_filter={false}
          player_class_filter={false}
          includes_filter={false}
          excludes_filter={false}
          class_stats_modal={false}
          search_filter={false}
          live_view={__MODULE__} />
      </div>
    </div>
    """
  end

  defp decks_params(archetype, params) do
    params
    |> shared_params()
    |> Map.put("player_deck_archetype", [archetype])
  end

  defp card_stats_params(archetype, params) do
    params
    |> shared_params()
    |> Map.put("archetype", archetype)
  end

  defp shared_params(params) do
    params
    |> Map.take(["format", "rank", "period"])
  end

  def replay_params(archetype) do
    %{"public" => true, "archetype" => archetype, "has_replay_url" => true}
  end

  defp parse_format_name(params) do
    params
    |> Map.get("format", 2)
    |> Util.to_int_or_orig()
    |> format_name()
  end

  def assign_meta(socket, _params), do: socket

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def handle_event("deck_expanded", %{"deckcode" => code}, socket) do
    Tracker.inc_expanded(code)
    {:noreply, socket}
  end
end
