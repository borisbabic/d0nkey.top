defmodule Components.Filter.PlayableCardSelect do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.Dropdown
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput

  prop(update_fun, :fun)
  prop(selected, :list, default: [])
  prop(title, :string, default: "Select cards")
  prop(search, :string, default: "")

  def render(assigns) do
    ~F"""
      <Dropdown title={"#{@title}"}>
        <Form for={%{}} as={:search} change="search" submit="search" opts={autocomplete: "off"}>
          <div class="columns is-mobile is-multiline">
            <div class="column is-narrow">
              <TextInput class="input" opts={placeholder: "Search"}/>
            </div>
          </div>
        </Form>
        <a class="dropdown-item is-active" :on-click="remove_card" :for={selected <- @selected} phx-value-card={selected}>
          {name(selected)}
        </a>
        <a class="dropdown-item" :for={card <- cards(@search, @selected)} :on-click="add_card" phx-value-card={card.id}>
          {card.name}
        </a>
      </Dropdown>

    """
  end

  def handle_event("search", %{"search" => [search]}, socket),
    do: {:noreply, assign(socket, :search, search)}

  def handle_event(
        "remove_card",
        %{"card" => card},
        socket = %{assigns: %{update_fun: update_fun, selected: selected}}
      ) do
    {id, _} = Integer.parse(card)
    update_fun.(selected -- [id])
    {:noreply, socket}
  end

  def handle_event(
        "add_card",
        %{"card" => card},
        socket = %{assigns: %{update_fun: update_fun, selected: selected}}
      ) do
    {id, _} = Integer.parse(card)
    update_fun.([id | selected])
    {:noreply, socket}
  end

  def cards(search, selected) do
    num_to_show = (7 - Enum.count(selected)) |> max(3)

    criteria = [
      {"collectible", true},
      {"order_by", "name_similarity_#{search}"},
      {"id_not_in", selected},
      {"limit", num_to_show}
    ]

    Backend.Hearthstone.cards(criteria)
  end

  def name(selected) do
    case Backend.HearthstoneJson.get_card(selected) do
      %{name: name} -> name
      _ -> nil
    end
  end

  def update_cards_fun(params, param, name \\ :update_params) do
    fn val ->
      new_params = Map.put(params, param, val)
      Process.send_after(self(), {name, new_params}, 0)
    end
  end
end
