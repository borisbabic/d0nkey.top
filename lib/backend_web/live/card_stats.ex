defmodule BackendWeb.CardStatsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.CardStatsTable
  alias Components.DecksExplorer

  data(user, :any)
  data(criteria, :map)
  data(filters, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2"> Card Stats </div>
      <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div><br>
        <CardStatsTable id="main_card_stats_table" filters={@filters} card_stats={stats(@criteria)} criteria={@criteria} live_view={__MODULE__}/>
      </div>
    """
  end

  defp stats(filters) do
    with [%{card_stats: card_stats}] <- Hearthstone.DeckTracker.agg_deck_card_stats(filters) do
      card_stats
    end
  end

  def handle_params(params, _uri, socket) do
    default = CardStatsTable.default_criteria(:public)
    decks_criteria = DecksExplorer.filter_relevant(params)

    criteria =
      Map.merge(default, decks_criteria)
      |> add_deck_id(params)

    filters = CardStatsTable.filter_relevant(params) |> CardStatsTable.with_default_filters()

    {:noreply, assign(socket, filters: filters, criteria: criteria)}
  end

  def add_deck_id(criteria, %{"deck_id" => id}),
    do: Map.put(criteria, "player_deck_id", Util.to_int_or_orig(id))

  def add_deck_id(criteria, %{"player_deck_id" => id}),
    do: Map.put(criteria, "player_deck_id", Util.to_int_or_orig(id))

  def add_deck_id(criteria, _), do: criteria
end
