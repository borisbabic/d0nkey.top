defmodule BackendWeb.CardStatsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Hearthstone.Deck
  alias Components.CardStatsTable
  alias Components.DecksExplorer

  data(user, :any)
  data(criteria, :map)
  data(filters, :map)
  data(deck, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context() |> assign_meta()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2"> Card Stats </div>
        <div :if={@deck} class="subtitle is-5">
          <a href={~p"/deck/#{@deck.id}"}>Deck Stats</a>
          <a :if={archetype = Deck.archetype(@deck)} href={~p"/card-stats?archetype=#{archetype}"}>Archetype Card Stats</a>
        </div>
      <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div><br>
        <CardStatsTable id="main_card_stats_table" filters={@filters} criteria={@criteria} live_view={__MODULE__}/>
      </div>
    """
  end

  defp deck_id(%{"player_deck_id" => deck_id}), do: deck_id
  defp deck_id(_), do: nil

  def handle_params(params, _uri, socket) do
    default = CardStatsTable.default_criteria(:public)
    decks_criteria = DecksExplorer.filter_relevant(params)

    criteria =
      Map.merge(default, decks_criteria)
      |> add_deck_id(params)

    filters = CardStatsTable.filter_relevant(params) |> CardStatsTable.with_default_filters()

    {:noreply,
     assign(socket, filters: filters, criteria: criteria) |> assign_deck() |> assign_meta()}
  end

  def add_deck_id(criteria, %{"deck_id" => id}),
    do: Map.put(criteria, "player_deck_id", Util.to_int_or_orig(id))

  def add_deck_id(criteria, %{"player_deck_id" => id}),
    do: Map.put(criteria, "player_deck_id", Util.to_int_or_orig(id))

  def add_deck_id(criteria, _), do: criteria

  def assign_deck(socket = %{assigns: %{criteria: %{"player_deck_id" => id}}}) do
    case Backend.Hearthstone.get_deck(id) do
      %Deck{} = deck ->
        socket
        |> assign(deck: deck)

      _ ->
        socket
    end
  end

  def assign_deck(socket), do: assign(socket, :deck, nil)

  def assign_meta(socket = %{assigns: %{deck: deck = %Deck{format: format}}}) do
    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Cards Stats for #{Deck.format_name(format)} #{Deck.name(deck)}",
      title: "#{Deck.name(deck)} Deck Card Stats (#{Deck.format_name(format)})"
    })
  end

  def assign_meta(socket = %{assigns: %{criteria: criteria = %{"archetype" => archetype}}}) do
    format_part =
      case Map.get(criteria, "format") do
        nil -> ""
        f -> "#{Deck.format_name(f)}"
      end

    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Cards Stats for #{format_part} #{archetype}",
      title: "#{archetype} Archetype Card Stats (#{format_part})"
    })
  end

  def assign_meta(socket), do: assign_generic_meta(socket)

  def assign_generic_meta(socket) do
    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Card Stats",
      title: "Card Stats"
    })
  end
end
