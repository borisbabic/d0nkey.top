defmodule Components.OmniBarResult do
  @moduledoc "Displays a single omni bar result"

  use Surface.Component

  prop(result, :map, required: true)

  def render(assigns) do
    ~F"""
      <a href={@result.link}>{@result.display_value}</a>
    """
  end
end
