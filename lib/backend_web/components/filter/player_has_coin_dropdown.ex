defmodule Components.Filter.PlayerHasCoinDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  prop(title, :string, default: "Coin?")
  prop(param, :string, default: "player_has_coin")
  prop(selected_as_title, :boolean, default: true)
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(live_view, :map, from_context: {Components.LivePatchDropdown, :live_view})
  prop(warning_triangle, :boolean, default: true)

  def render(assigns) do
    ~F"""
      <span>
        <LivePatchDropdown
        options={options(@warning_triangle)}
        title={@title}
        param={@param}
        url_params={@url_params}
        path_params={@path_params}
        selected_params={@selected_params}
        live_view={@live_view}
        />
      </span>
    """
  end

  defp options(warning_triangle) do
    [
      {nil, "Any Player"},
      {"no", with_triangle("Going First", warning_triangle)},
      {"yes", with_triangle("On Coin", warning_triangle)}
    ]
  end

  defp with_triangle(text, false), do: text
  defp with_triangle(text, true), do: Components.Helper.warning_triangle(%{before: text})
end
