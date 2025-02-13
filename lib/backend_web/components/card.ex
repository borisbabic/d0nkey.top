defmodule Components.Card do
  @moduledoc false
  use BackendWeb, :surface_component

  alias Backend.Hearthstone.Card
  prop(card, :map, required: true)
  prop(shrink_mobile, :boolean, default: false)
  prop(disable_link, :boolean, default: false)
  slot(above_image, required: false)
  slot(below_image, required: false)

  def render(assigns) do
    ~F"""
      <a href={~p"/card/#{@card}"} class={"tw-relative", "has-no-pointer-events": @disable_link}>
        <#slot {@above_image, card: @card} />
        <img src={Card.card_url(@card)} alt={@card.name} class={"tw-w-64": !@shrink_mobile, "tw-w-48": @shrink_mobile, "lg:tw-w-64": @shrink_mobile, "md:tw-w-64": @shrink_mobile}/>
        <#slot {@below_image, card: @card} />
      </a>
    """
  end

  # <div clas="tw-relative">
  # </div>
end
