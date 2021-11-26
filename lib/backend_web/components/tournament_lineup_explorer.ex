defmodule Components.TournamentLineupExplorer do
  @moduledoc false
  use Surface.LiveComponent

  prop(tournament_id, :string)
  prop(tournament_source, :string)
  prop(filters, :map, default: %{"decks" => []})
  prop(temp_filters, :map, default: %{})
  prop(show_modal, :boolean, default: false)
  prop(page, :integer, default: 1)
  prop(page_size, :integer, default: 50)
  prop(show_page_dropdown, :boolean, default: true)
  prop(gm_week, :string, default: nil)
  slot(default)

  alias Components.GMProfileLink
  alias Components.ExpandableLineup
  alias Components.Dropdown
  alias Components.Filter.PlayableCardSelect
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Backend.Hearthstone.Deck

  def render(assigns) do
    ~F"""
    <div>
      <div :if={lineups = lineups(@tournament_id, @tournament_source, @filters)}>
        <#slot />
        <Dropdown title="Page" :if={@show_page_dropdown}>
          <a :for={page <- page_range(lineups, @page_size)}class={"dropdown-item #{page == @page && 'is-active' || ''}"} :on-click="set-page" phx-value-page={page} >
            {page}
          </a>
        </Dropdown>
        <button class="button" type="button" :on-click="show_modal">Filter</button>
        <div>Total: {lineups |> Enum.count()}</div>
        <div class="modal is-active" :if={@show_modal}>
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">Filter Decks</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body" style="min-height: 400px;">
              <div :for.with_index={{deck, index} <- decks(@temp_filters)} class="level">
                <div class="level-left">
                  <button class="button level-item" type="button" :on-click="remove_deck" phx-value-index={index}>Remove deck</button>
                  <Dropdown title={"#{deck["class"] && deck["class"] |> Deck.class_name() || "Class"}"}>
                    <a class={"dropdown-item #{deck["class"] == class && 'is-active' || ''}"} :for={class <- Deck.classes()} :on-click="filter-class" phx-value-index={index} phx-value-class={class}>
                      {class |> Deck.class_name()}
                    </a>
                  </Dropdown>
                  <PlayableCardSelect id={"include_cards_deck_#{index}"} update_fun={update_cards(@id, @temp_filters, index, "include_cards")} selected={deck["include_cards"]} title="Include cards"/>
                  <PlayableCardSelect id={"exclude_cards_deck_#{index}"} update_fun={update_cards(@id, @temp_filters, index, "exclude_cards")} selected={deck["exclude_cards"]} title="Exclude cards"/>

                </div>
              </div>
            </section>
            <footer class="modal-card-foot">
              <button class="button" type="button" :on-click="add_deck">Add deck</button>
              <button class="button" type="button" aria-label="close" :on-click="save_filters">Save</button>
            </footer>
          </div>
        </div>
        <table class="table is-fullwidth is-striped">
          <thead>
            <tr>
              <th>Name</th>
              <th>Decks</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={lineup <- lineups |> paginate(@page, @page_size)}>
              <td :if={@gm_week}> <GMProfileLink week={@gm_week} gm={lineup.name}/> </td>
              <td :if={!@gm_week}>{lineup.name}</td>
              <td>
                <ExpandableLineup lineup={lineup} id={"modal_lineup_#{lineup.id}"}/>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp paginate(lineups, page, page_size) do
    lineups |> Enum.slice((page - 1) * page_size, page_size)
  end

  defp page_range(elements, size) do
    max = (Enum.count(elements) / size) |> Float.ceil() |> trunc()
    1..max
  end

  def lineups(tournament_id, tournament_source, filters) do
    filters
    |> Map.merge(%{"tournament_id" => tournament_id, "tournament_source" => tournament_source})
    |> Backend.Hearthstone.lineups()
  end

  def update_cards(id, temp_filters, index, param) do
    fn value ->
      new_temp_filters = update_temp_filters(temp_filters, index, param, value)
      send_update(__MODULE__, id: id, temp_filters: new_temp_filters)
    end
  end

  def update_temp_filters(%{assigns: %{temp_filters: temp_filters}}, deck_index, key, val),
    do: update_temp_filters(temp_filters, deck_index, key, val)

  def update_temp_filters(temp_filters, deck_index, key, val) do
    decks = temp_filters |> decks()

    deck =
      decks
      |> Enum.at(deck_index)
      |> Map.put(key, val)

    new_decks = decks |> List.replace_at(deck_index, deck)
    temp_filters |> Map.put("decks", new_decks)
  end

  def handle_event("set-page", %{"page" => page_raw}, socket) do
    {page, _} = Integer.parse(page_raw)
    {:noreply, socket |> assign(page: page)}
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true, temp_filters: socket.assigns.filters)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false)}
  end

  def handle_event("save_filters", _, socket) do
    {:noreply,
     socket
     |> assign(
       filters: socket.assigns.temp_filters,
       show_modal: false
     )}
  end

  def handle_event(
        "filter-class",
        %{"index" => index_raw, "class" => class},
        socket
      ) do
    {index, _} = Integer.parse(index_raw)

    new_temp_filters = update_temp_filters(socket, index, "class", class)
    {:noreply, socket |> assign(temp_filters: new_temp_filters)}
  end

  def handle_event(
        "remove_deck",
        %{"index" => index_raw},
        socket = %{assigns: %{temp_filters: temp_filters}}
      ) do
    {index, _} = Integer.parse(index_raw)

    decks = temp_filters |> decks() |> List.delete_at(index)
    new_temp_filters = temp_filters |> Map.put("decks", decks)
    {:noreply, socket |> assign(temp_filters: new_temp_filters)}
  end

  def handle_event("add_deck", _, socket = %{assigns: %{temp_filters: temp_filters}}) do
    decks = temp_filters |> decks() |> Kernel.++([empty_deck_filter()])

    new_temp_filters = temp_filters |> Map.put("decks", decks)

    {:noreply, socket |> assign(temp_filters: new_temp_filters)}
  end

  def empty_deck_filter(), do: %{"include_cards" => [], "exclude_cards" => []}
  def decks(%{"decks" => d}) when is_list(d), do: d
  def decks(_), do: []
end
