defmodule Components.Helper do
  use Phoenix.Component

  def warning_triangle(), do: warning_triangle(%{})
  attr :before, :any, required: false

  def warning_triangle(assigns) do
    ~H"""
    <span :if={@before}><%= @before %></span>
    <HeroIcons.warning_triangle size="small" />
    """
  end
end
