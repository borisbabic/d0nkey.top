defmodule Components.Card do
  @moduledoc false
  use BackendWeb, :surface_component

  alias Backend.Hearthstone.Card
  prop(card, :map, required: true)
  prop(shrink_mobile, :boolean, default: false)
  prop(disable_link, :boolean, default: false)
  prop(hide_name, :boolean, default: false)
  prop(hide_text_and_stats, :boolean, default: false)
  slot(above_image, required: false)
  slot(below_image, required: false)

  def render(assigns) do
    ~F"""
      <a href={~p"/card/#{@card}"} class={"tw-relative", "card-image-container", "has-no-pointer-events": @disable_link}>
        <#slot {@above_image, card: @card} />
        <img src={Card.card_url(@card)} alt={@card.name} class={"md:tw-w-64", "tw-w-64": !@shrink_mobile, "tw-w-48": @shrink_mobile}/>
        <#slot {@below_image, card: @card} />

        <div :if={@hide_name} class={
          "hide-card-image", "tw-absolute", "tw-block", "tw-z-[4]", "tw-bg-black",
          # mid+ devices
          "md:tw-top-[150px]", "md:tw-left-[28px]", "md:tw-h-[50px]", "md:tw-w-[190px]",
          # same when as above when not shrinking mobile
          "tw-top-[150px]": !@shrink_mobile, "tw-left-[28px]": !@shrink_mobile, "tw-h-[50px]": !@shrink_mobile, "tw-w-[190px]": !@shrink_mobile,
          # smaller for shrinked
          "tw-top-[115px]": @shrink_mobile, "tw-left-[24px]": @shrink_mobile, "tw-h-[40px]": @shrink_mobile, "tw-w-[135px]": @shrink_mobile
        }/>
        <div :if={@hide_text_and_stats} class={
          "hide-card-text", "tw-absolute", "tw-block", "tw-z-[4]", "tw-bg-black",
          # mid+ devices
          "md:tw-top-[200px]", "md:tw-left-[28px]", "md:tw-h-[110px]", "md:tw-w-[190px]",
          # same when as above when not shrinking mobile
          "tw-top-[200px]": !@shrink_mobile, "tw-left-[28px]": !@shrink_mobile, "tw-h-[110px]": !@shrink_mobile, "tw-w-[190px]": !@shrink_mobile,
          # smaller for shrinked
          "tw-top-[155px]": @shrink_mobile, "tw-left-[24px]": @shrink_mobile, "tw-h-[85px]": @shrink_mobile, "tw-w-[135px]": @shrink_mobile
        }/>
      </a>
    """
  end

  # <div clas="tw-relative">
  # </div>
end
