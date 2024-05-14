defmodule Components.Helper do
  use Phoenix.Component

  def warning_triangle(), do: warning_triangle(%{})

  attr :before, :any, required: false, default: false

  def warning_triangle(assigns) do
    ~H"""
    <span>
      <span :if={@before}><%= @before %></span>
      <HeroIcons.warning_triangle size="small" />
    </span>
    """
  end

  def concat(first, second) do
    concat(%{first: first, second: second})
  end

  attr :first, :any, required: true
  attr :second, :any, required: true

  def concat(assigns) do
    ~H"""
    <%= @first %><%=@second%>
    """
  end
end
