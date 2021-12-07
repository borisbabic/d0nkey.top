defmodule Components.DeckStats do
  @moduledoc false
  use Surface.Component
  prop(total, :number, required: false)
  prop(winrate, :number, required: false)
  prop(element_class, :css_class, default: "")
  def render(assigns) do
    ~F"""
      <div :if={@winrate} class={"column", "tag"} style={winrate_style(@winrate)}>
        {Float.round(@winrate * 100, 1)} %
      </div>
      <div :if={@total} class="column tag">
        Games: {@total}
      </div>
    """
  end

  def winrate_style(winrate) do
    red = 255 - 255 * winrate
    green = 255 * winrate
    blue = min(red, green)
    "background-color: rgb(#{red}, #{green}, #{blue}"
  end
end
