defmodule Components.Card do
  @moduledoc false
  use BackendWeb, :surface_component

  alias Backend.Hearthstone.Card
  prop(card, :map, required: true)
  prop(shrink_mobile, :boolean, default: false)
  prop(disable_link, :boolean, default: false)
  slot(above_image, required: false)

  def render(assigns) do
    ~F"""
      <a href={~p"/card/#{@card}"} class={"tw-relative", "has-no-pointer-events": @disable_link}>
        <img src={Card.card_url(@card)} alt={@card.name} class={"tw-w-64": !@shrink_mobile, "tw-w-48": @shrink_mobile, "lg:tw-w-64": @shrink_mobile, "md:tw-w-64": @shrink_mobile}/>
        <div class="tw-inline-block tw-text-center tw-absolute tw-top-0 tw-z-1 has-text-white tw-w-full">
          <#slot {@above_image, card: @card} />
        </div>
      </a>
    """
  end
end
