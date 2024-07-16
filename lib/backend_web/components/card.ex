defmodule Components.Card do
  @moduledoc false
  use BackendWeb, :surface_component

  alias Backend.Hearthstone.Card
  prop(card, :map, required: true)
  prop(disable_link, :boolean, default: false)

  def render(assigns) do
    ~F"""
      <a href={~p"/card/#{@card}"} class={"has-no-pointer-events": @disable_link}>
        <image src={Card.card_url(@card)} alt={@card.name} width="256"/>
      </a>
    """
  end
end
