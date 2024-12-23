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
  prop(param, :string, required: true)
  prop(format, :any, default: nil)

  def render(assigns) do
    ~F"""
    <span>
      <MultiSelectDropdown
      id={"#{@id}_pcs_ms_id"}
      show_search={true}
      param={@param}
      options={cards(@search, @selected, @canonicalize, @format)}
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

  def cards(search, selected, canonicalize?, format) do
    num_to_show = (7 - Enum.count(selected)) |> max(3)

    criteria =
      [
        {"collectible", true},
        {"order_by", "name_similarity_#{search}"},
        {"id_not_in", selected},
        # hack because "zill" didn't show zilliax deluxe 3000 on prod when limiting to num_to_show
        # I'm kinda fine-ish with it because filter_canonical could reduce below the number anyways
        # 100 is probably overkill but I don't think it's that expensive
        {"limit", 100}
      ]
      |> add_format(format)

    selected_options = to_options(selected)

    Backend.Hearthstone.cards(criteria)
    # |> tap(fn cards ->  cards |> Enum.map(& &1.name) |> Enum.sort() |> Enum.join("\n") |> IO.puts() end)
    |> filter_canonical(canonicalize?)
    |> Enum.take(num_to_show)
    |> Enum.map(fn c ->
      {Card.dbf_id(c), Card.name(c)}
    end)
    |> Kernel.++(selected_options)
  end

  defp add_format(criteria, format) when format in [1, "1", "wild", "Wild"],
    do: [{"card_set_group_slug", "wild"} | criteria]

  defp add_format(criteria, format) when format in [2, "2", "standard", "Standard"],
    do: [{"card_set_group_slug", "standard"} | criteria]

  defp add_format(criteria, _format), do: criteria

  defp filter_canonical(cards, true) do
    # do it like this because if we filter for formats the canonical may not be in the format
    # so if there is only one we don't filter it out
    # maybe change the concept from canonicalizing then
    to_drop =
      cards
      |> Enum.group_by(fn %{id: id} -> Backend.Hearthstone.canonical_id(id) end)
      |> Enum.flat_map(fn
        {_canonical_id, [_card]} ->
          []

        {canonical_id, cards} ->
          to_keep =
            Enum.find(cards, &(&1.id == canonical_id)) ||
              Enum.find(cards, &(&1.id == Backend.Hearthstone.CardBag.deckcode_copy_id(&1.id))) ||
              Enum.min_by(cards, & &1.id)

          Enum.filter(cards, &(&1.id != to_keep.id))
      end)
      |> MapSet.new(& &1.id)

    Enum.reject(cards, &MapSet.member?(to_drop, &1.id))
  end

  defp filter_canonical(cards, false), do: cards

  def name(selected) do
    case Backend.HearthstoneJson.get_card(selected) do
      %{name: name} -> name
      _ -> nil
    end
  end
end
