defmodule Components.Filter.PlayableCardSelect do
  @moduledoc false
  use Surface.LiveComponent
  alias FunctionComponents.Dropdown
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput

  prop(update_fun, :fun)
  prop(selected, :list, default: [])
  prop(title, :string, default: "Select cards")
  prop(search, :string, default: "")
  prop(canonicalize, :boolean, default: true)

  def render(assigns) do
    ~F"""
    <span>
      <Dropdown.menu title={"#{@title}"}>
        <Form for={%{}} as={:search} change="search" submit="search" opts={autocomplete: "off"}>
          <TextInput id={"#{@id}_search"} class="input has-text-black " opts={placeholder: "Search"}/>
        </Form>
        <Dropdown.item selected={true} phx-target={@myself} phx-click="remove_card" :for={selected <- @selected} phx-value-card={selected}>
          {name(selected)}
        </Dropdown.item>
        <Dropdown.item selected={false} class="dropdown-item" :for={card <- cards(@search, @selected, @canonicalize)} phx-target={@myself} phx-click="add_card" phx-value-card={card.id}>
          {card.name}
        </Dropdown.item>
      </Dropdown.menu>
    </span>
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

    case update_fun.(selected -- [id]) do
      {:redirect, opts} -> {:noreply, redirect(socket, opts)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event(
        "add_card",
        %{"card" => card},
        socket = %{assigns: %{update_fun: update_fun, selected: selected}}
      ) do
    {id, _} = Integer.parse(card)

    case update_fun.([id | selected]) do
      {:redirect, opts} -> {:noreply, redirect(socket, opts)}
      _ -> {:noreply, socket}
    end
  end

  def cards(search, selected, canonicalize?) do
    num_to_show = (7 - Enum.count(selected)) |> max(3)

    criteria = [
      {"collectible", true},
      {"order_by", "name_similarity_#{search}"},
      {"id_not_in", selected},
      # hack because "zill" didn't show zilliax deluxe 3000 on prod when limiting to num_to_show
      # I'm kinda fine-ish with it because filter_canonical could reduce below the number anyways
      # 100 is probably overkill but I don't think it's that expensive
      {"limit", 100}
    ]

    Backend.Hearthstone.cards(criteria)
    |> filter_canonical(canonicalize?)
    |> Enum.take(num_to_show)
  end

  defp filter_canonical(cards, true) do
    Enum.filter(cards, fn %{id: id} ->
      Backend.Hearthstone.canonical_id(id) == id
    end)
  end

  defp filter_canonical(cards, false), do: cards

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
