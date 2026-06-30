defmodule Components.ViewHelpers.PlayerHelper do
  use BackendWeb, :component
  attr :competition, :string, required: true
  attr :position, :integer, required: true
  attr :score, :string, required: true

  def table_row(assigns) do
    ~H"""
      <.trb>
        <.td> <%= @competition %> </.td>
        <.td> <%= @position %> </.td>
        <.td> <%= @score %> </.td>
      </.trb>
    """
  end

  attr :headers, :list, default: ["Competition", "Place", "Score"]

  def table_headers(assigns) do
    ~H"""
      <%= for h <- @headers do %>
        <.th><%= h %></.th>
      <% end %>
    """
  end
end
