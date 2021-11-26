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
        <Form for={:search} change="search" submit="search" opts={autocomplete: "off"}>
          <div class="columns is-mobile is-multiline">
            <div class="column is-narrow">
              <TextInput class="input" opts={placeholder: "Search"}/>
            </div>
          </div>
        </Form>
        <a class="dropdown-item is-active" :on-click="remove_card" :for={selected <- @selected} phx-value-card={selected}>
          {Backend.HearthstoneJson.get_card(selected).name}
        </a>
        <a class="dropdown-item" :for={card <- cards(@search, @selected)} :on-click="add_card" phx-value-card={card.dbf_id}>
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
    {dbf_id, _} = Integer.parse(card)
    update_fun.(selected -- [dbf_id])
    {:noreply, socket}
  end

  def handle_event(
        "add_card",
        %{"card" => card},
        socket = %{assigns: %{update_fun: update_fun, selected: selected}}
      ) do
    {dbf_id, _} = Integer.parse(card)
    update_fun.([dbf_id | selected])
    {:noreply, socket}
  end

  def cards(search, selected) do
    num_to_show = (7 - Enum.count(selected)) |> max(3)

    Backend.HearthstoneJson.playable_cards()
    |> Enum.filter(&(String.downcase(&1.name) =~ String.downcase(search)))
    |> Enum.filter(&(!(&1.dbf_id in selected)))
    |> Enum.take(num_to_show)
  end
end
