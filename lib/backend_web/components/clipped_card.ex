defmodule Components.ClippedCard do
  @moduledoc false
  use BackendWeb, :surface_component

  alias Backend.Hearthstone.Card
  prop(card, :map, required: true)

  def render(assigns) do
    ~F"""
      <a href={~p"/card/#{@card}"} >
        <div style={"background-image: url(#{Card.card_url(@card)}); height:32px; width:32px; background-size: 101px 180px; background-position: 50% 23%;"} role="img">
        </div>
      </a>
    """
  end
end
