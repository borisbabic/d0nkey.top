defmodule Components.Filter.ArchetypeSelect do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.Dropdown
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput
  alias Hearthstone.DeckTracker.ArchetypeBag
  prop(update_fun, :fun)
  prop(selected, :list, default: [])
  prop(title, :string, default: "Select Archetype")
  prop(search, :string, default: "")
  prop(selectable_archetypes, :list, default: [])
  prop(criteria, :list, default: [{"latest", 60 * 12}])

  def render(assigns) do
    ~F"""
      <Dropdown title={"#{@title}"}>
        <Form for={%{}} as={:search} change="search" submit="search" opts={autocomplete: "off"}>
          <div class="columns is-mobile is-multiline">
            <div class="column is-narrow">
              <TextInput class="input has-text-black " opts={placeholder: "Search"}/>
            </div>
          </div>
        </Form>
        <a class="dropdown-item is-active" :on-click="remove_archetype" :for={selected <- @selected} phx-value-archetype={selected}>
          {selected}
        </a>
        <a class="dropdown-item" :for={archetype <- archetypes(@search, @selected, @selectable_archetypes, @criteria)} :on-click="add_archetype" phx-value-archetype={archetype}>
          {archetype}
        </a>
      </Dropdown>

    """
  end

  def handle_event("search", %{"search" => [search]}, socket),
    do: {:noreply, assign(socket, :search, search)}

  def handle_event(
        "remove_archetype",
        %{"archetype" => archetype},
        socket = %{assigns: %{update_fun: update_fun, selected: selected}}
      ) do
    update_fun.(selected -- [archetype])
    {:noreply, socket}
  end

  def handle_event(
        "add_archetype",
        %{"archetype" => archetype},
        socket = %{assigns: %{update_fun: update_fun, selected: selected}}
      ) do
    update_fun.([archetype | selected])
    {:noreply, socket}
  end

  def archetypes(search, selected, selectable_archetypes, criteria) do
    num_to_show = (7 - Enum.count(selected)) |> max(3)

    (archetypes(selectable_archetypes, criteria) || [])
    |> Enum.filter(&(String.downcase(to_string(&1)) =~ String.downcase(search)))
    |> Enum.reject(&(to_string(&1) in selected))
    |> Enum.take(num_to_show)
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

  def update_archetypes_fun(params, param, name \\ :update_params) do
    fn val ->
      new_params = Map.put(params, param, val)
      Process.send_after(self(), {name, new_params}, 0)
    end
  end
end
