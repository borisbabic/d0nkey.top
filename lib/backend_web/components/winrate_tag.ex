defmodule Components.WinrateTag do
  @moduledoc false
  # use Surface.Component
  use BackendWeb, :surface_component
  alias FunctionComponents.Stats
  # import Phoenix.Component, only: [dynamic_tag: 1]

  prop(winrate, :number, required: true)
  prop(round_digits, :number, default: 1)
  prop(positive_hue, :number, default: 120)
  prop(negative_hue, :number, default: 0)
  prop(tag_name, :string, default: "span")
  prop(class, :css_class, default: "tag")
  prop(lightness, :number, default: 50)
  prop(base_saturation, :number, default: 5)
  prop(show_sample, :number, default: false)
  prop(min_sample, :number, default: 1)
  prop(sample, :number, default: nil)
  prop(impact, :boolean, default: false)
  prop(win_loss, :any, default: nil)

  def render(assigns) do
    ~F"""
      <Stats.winrate_tag min_sample={@min_sample} winrate={@winrate} round_digits={@round_digits} positive_hue={@positive_hue} negative_hue={@negative_hue} tag_name={@tag_name} class={@class} lightness={@lightness} base_saturation={@base_saturation} sample={@sample} impact={@impact} show_sample={@show_sample}/>
    """
  end

  defdelegate winrate_style(
                winrate,
                positive_hue,
                negative_hue,
                lightness,
                base_saturation,
                sample \\ nil
              ),
              to: Stats
end
