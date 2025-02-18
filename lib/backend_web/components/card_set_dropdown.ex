defmodule Components.Filter.CardSetDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.MultiSelectDropdown
  prop(title, :string, default: "Card Set")
  prop(param, :string, default: "card_set_id")
  prop(group_slug, :string, default: nil)
  prop(options, :list, default: nil)
  data(show_search, :boolean)
  data(selected_to_top, :boolean)

  def render(assigns) do
    ~F"""
    <span>
      <MultiSelectDropdown options={@options}
      id={"#{@id}_multi_select"}
      title={@title}
      selected_as_title={false}
      selected_to_top={@selected_to_top}
      show_search={@show_search}
      num_to_show={696969}
      normalizer={&Util.to_int_or_orig/1}
      param={@param}/>
    </span>
    """
  end

  def options(group_slug) do
    Backend.Hearthstone.latest_sets_with_release_dates(group_slug)
    |> Enum.map(&{&1.id, &1.name})
  end

  def update(assigns, socket) do
    %{group_slug: group_slug} = assigns
    options = Map.get(assigns, :options) || options(group_slug)
    show_search = Enum.count(options) > 10
    selected_to_top = Enum.count(options) > 20

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(options: options, show_search: show_search, selected_to_top: selected_to_top)
    }
  end
end
