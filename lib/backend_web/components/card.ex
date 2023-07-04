defmodule Components.Card do
  @moduledoc false
  use BackendWeb, :surface_component

  alias Backend.Hearthstone.Card
  prop(card, :map, required: true)

  def render(assigns) do
    ~F"""
      <a href={~p"/card/#{@card}"}>
        <image src={Card.card_url(@card)} alt={@card.name} width="256"/>
      </a>
    """
  end
end
