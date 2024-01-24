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
  data(params, :map)
  data(highlight_cards, :list)
  data(title, :string)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context() |> assign_meta()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">{@title || "Card Stats"}</div>
        <div class="subtitle is-6">
          <span :if={@deck}><a href={~p"/deck/#{@deck.id}"}> Deck Stats</a> | </span>
          <span :if={archetype = Deck.archetype(@deck)}><a href={~p"/card-stats?#{create_archetype_filters(@params, archetype)}"}>Archetype Card Stats</a> | </span>
           <a href={~p"/stats/explanation"}>Stats Explanation</a> | To contribute use <a href="https://www.firestoneapp.com/" target="_blank">Firestone</a>
        </div>
      <FunctionComponents.Ads.below_title/>
        <CardStatsTable highlight_cards={@highlight_cards} params={@params}id="main_card_stats_table" filters={@filters} card_stats={stats(@criteria) || []} criteria={@criteria} live_view={__MODULE__}/>
      </div>
    """
  end

  defp create_archetype_filters(params, archetype) do
    base_filters =
      case Map.pop(params, "deck_id") do
        {nil, rest} -> rest
        {deck_id, rest} -> Map.put(rest, "highlight_deck", deck_id)
      end

    Map.put(base_filters, "archetype", archetype)
  end

  defp stats(filters) do
    with [%{card_stats: card_stats}] <- Hearthstone.DeckTracker.agg_deck_card_stats(filters) do
      card_stats
    end
  end

  defp deck_id(%{"player_deck_id" => deck_id}), do: deck_id
  defp deck_id(_), do: nil

  def handle_params(params, _uri, socket) do
    default = CardStatsTable.default_criteria(:public)
    decks_criteria = DecksExplorer.filter_relevant(params)
    highlight_cards = highlight_cards(params)

    criteria =
      Map.merge(default, decks_criteria)
      |> add_deck_id(params)

    filters = CardStatsTable.filter_relevant(params) |> CardStatsTable.with_default_filters()

    {:noreply,
     assign(socket,
       filters: filters,
       criteria: criteria,
       params: params,
       highlight_cards: highlight_cards
     )
     |> assign_deck()
     |> assign_meta()}
  end

  def highlight_cards(params) do
    cards_from_deck =
      with id when not is_nil(id) <- Map.get(params, "highlight_deck"),
           %{cards: cards} <- Backend.Hearthstone.get_deck(id) do
        cards
      else
        _ -> []
      end

    cards_from_params =
      Map.get(params, "highlight_cards", [])
      |> Util.to_list()
      |> Enum.map(&Util.to_int_or_orig/1)
      |> Enum.filter(&is_integer/1)

    Enum.uniq(cards_from_deck ++ cards_from_params)
    |> Deck.canonicalize_cards()
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
    title = "#{Deck.name(deck)} Deck Card Stats (#{Deck.format_name(format)})"

    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Cards Stats for #{Deck.format_name(format)} #{Deck.name(deck)}",
      title: title
    })
    |> assign(title: title)
  end

  def assign_meta(socket = %{assigns: %{criteria: criteria = %{"archetype" => archetype}}}) do
    format_part =
      case Map.get(criteria, "format") do
        nil -> ""
        f -> "#{Deck.format_name(f)}"
      end

    title = "#{archetype} Archetype Card Stats (#{format_part})"

    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Cards Stats for #{format_part} #{archetype}",
      title: title
    })
    |> assign(title: title)
  end

  def assign_meta(socket), do: assign_generic_meta(socket)

  def assign_generic_meta(socket) do
    title = "Card Stats"

    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Card Stats",
      title: title
    })
    |> assign(title: title)
  end
end
