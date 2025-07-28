defmodule Components.Filter.ArchetypeSelect do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.MultiSelectDropdown
  alias Hearthstone.DeckTracker.ArchetypeBag
  prop(selected, :list, default: [])
  prop(title, :string, default: "Select Archetype")
  prop(search, :string, default: "")
  prop(param, :string, required: true)
  prop(selectable_archetypes, :list, default: [])
  prop(updater, :fun, default: &MultiSelectDropdown.update_selected/2)
  prop(criteria, :list, default: [{"latest", 60 * 12}])

  def render(assigns) do
    ~F"""
      <span>
      <MultiSelectDropdown
        id={"#{@id}_as_ms_id"}
        show_search={true}
        param={@param}
        selected={@selected}
        updater={@updater}
        options={archetypes(@search, @selected, @selectable_archetypes, @criteria)}
        title={@title}
        search_event={"search"}
        selected_as_title={false}
        />
      </span>
    """
  end

  def handle_event("search", %{"search" => search}, socket) when is_binary(search),
    do: {:noreply, assign(socket, :search, search)}

  def archetypes(search, selected, selectable_archetypes, criteria) do
    num_to_show = (7 - Enum.count(selected)) |> max(3)

    (archetypes(selectable_archetypes, criteria) || [])
    |> Enum.filter(&(String.downcase(to_string(&1)) =~ String.downcase(search)))
    |> Enum.reject(&(to_string(&1) in selected))
    |> Enum.take(num_to_show)
    |> Kernel.++(selected)
  end

  defp archetypes([], criteria) do
    case List.keyfind(criteria, "format", 0) do
      {"format", format} when is_integer(format) or is_binary(format) ->
        ArchetypeBag.get_archetypes(format)

      _ ->
        ArchetypeBag.get_archetypes()
    end
  end

  defp archetypes(selectable, _), do: selectable
end
