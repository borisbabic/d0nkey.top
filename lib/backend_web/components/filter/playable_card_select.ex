defmodule Components.Filter.PlayableCardSelect do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.MultiSelectDropdown
  alias Backend.Hearthstone.Card

  prop(selected, :list, default: [])
  prop(title, :string, default: "Select cards")
  prop(search, :string, default: "")
  prop(canonicalize, :boolean, default: true)
  prop(updater, :fun, default: &MultiSelectDropdown.update_selected/2)

  def render(assigns) do
    ~F"""
    <span>
      <MultiSelectDropdown
      id={"#{@id}_pcs_ms_id"}
      show_search={true}
      param={@param}
      options={cards(@search, @selected, @canonicalize)}
      title={@title}
      search_event={"search"}
      selected_to_top={true}
      updater={@updater}
      current_val={@selected}
      normalizer={&Util.to_int_or_orig/1}
      selected_as_title={false}
      />
    </span>
    """
  end

  def handle_event("search", %{"search" => [search]}, socket),
    do: {:noreply, assign(socket, :search, search)}

  defp to_options(selected) do
    Enum.map(selected, fn id_raw ->
      id = Util.to_int_or_orig(id_raw)
      name = name(id)
      {id, name}
    end)
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

    selected_options = to_options(selected)

    Backend.Hearthstone.cards(criteria)
    |> filter_canonical(canonicalize?)
    |> Enum.take(num_to_show)
    |> Enum.map(fn c ->
      {Card.dbf_id(c), Card.name(c)}
    end)
    |> Kernel.++(selected_options)
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
end
