defmodule Components.WinrateTag do
  @moduledoc false
  use Surface.Component

  prop(winrate, :number, required: true)
  prop(shift_for_color, :number, default: 0)
  prop(round_digits, :number, default: 2)
  prop(positive_hue, :number, default: 120)
  prop(negative_hue, :number, default: 0)
  prop(class, :css_class)
  prop(lightness, :number, default: 50)
  prop(base_saturation, :number, default: 5)

  def render(assigns) do
    ~F"""
    <span class={"tag", @class} style={winrate_style(@winrate + @shift_for_color, @positive_hue, @negative_hue, @lightness, @base_saturation)}>
      <span class={"basic-black-text"}>
        {round(@winrate, @round_digits)}
      </span>
    </span>
    """
  end

  def winrate_style(winrate, positive_hue, negative_hue, lightness, base_saturation) do
    hue =
      if winrate >= 0.5 do
        positive_hue
      else
        negative_hue
      end

    saturation = base_saturation + (100 - base_saturation) * (abs(winrate - 0.5) / 0.5)
    "background-color: hsl(#{hue}, #{saturation}%, #{lightness}%"
  end

  def round(int, _) when is_integer(int), do: int / 1
  def round(float, digits), do: Float.round(float * 100, digits)
end
