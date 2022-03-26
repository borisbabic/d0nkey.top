defmodule Components.Helper do
  use Phoenix.Component

  def warning_triangle(assigns \\ %{}) do
    ~H"""
      <span class="icon is-small">
        <i class="fas fa-exclamation-triangle"></i>
      </span>
    """
  end
end
