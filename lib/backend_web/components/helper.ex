defmodule Components.Helper do
  use Phoenix.Component

  def warning_triangle(assigns \\ %{before: nil}) do
    ~H"""
    <span :if={@before}><%= @before %></span>
    <span class="icon is-small">
        <i class="fas fa-exclamation-triangle"></i>
      </span>
    """
  end
end
