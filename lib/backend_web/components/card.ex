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
      <a href={if @disable_link, do: "javascript:;", else: ~p"/card/#{@card}"} class={"tw-relative", "card-image-container", "has-no-pointer-events": @disable_link}>
        <#slot {@above_image, card: @card} />
        <img src={Card.card_url(@card)} alt={@card.name} class={"md:tw-w-64", "tw-w-64": !@shrink_mobile, "tw-w-48": @shrink_mobile}/>
        <#slot {@below_image, card: @card} />

        <div :if={@hide_name} class={hide_name_classes(@shrink_mobile)}/>
        <div :if={@hide_text_and_stats} class={hide_text_and_stats_classes(@shrink_mobile)}/>
      </a>
    """
  end

  defp hide_name_classes(shrink_mobile) do
    base =
      "hide-card-image tw-absolute tw-block tw-z-[4] tw-bg-black md:tw-top-[150px] md:tw-left-[28px] md:tw-h-[50px] md:tw-w-[190px] "

    variable_part =
      if shrink_mobile do
        " tw-top-[115px] tw-left-[24px] tw-h-[40px] tw-w-[135px]"
      else
        " tw-top-[150px] tw-left-[28px] tw-h-[50px] tw-w-[190px]"
      end

    base <> variable_part
  end

  def hide_text_and_stats_classes(shrink_mobile) do
    base =
      "hide-card-text tw-absolute tw-block tw-z-[4] tw-bg-black md:tw-top-[200px] md:tw-left-[28px] md:tw-h-[110px] md:tw-w-[190px] "

    variable_part =
      if shrink_mobile do
        " tw-top-[155px] tw-left-[24px] tw-h-[85px] tw-w-[135px]"
      else
        " tw-top-[200px] tw-left-[28px] tw-h-[110px] tw-w-[190px]"
      end

    base <> variable_part
  end
end
