defmodule Components.Helper do
  use Phoenix.Component

  def warning_triangle(assigns \\ %{before: nil}) do
    ~H"""
    <span :if={@before}><%= @before %></span>
    <HeroIcons.warning_triangle size="small" />
    """
  end
end
