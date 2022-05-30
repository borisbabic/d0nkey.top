defmodule Components.WinrateTag do
  @moduledoc false
  use Surface.Component

  prop(winrate, :number, required: true)

  def render(assigns) do
    ~F"""
    <span class="tag" style={winrate_style(@winrate)}>
      <span class={"basic-black-text"}>
        {Float.round(@winrate * 100, 1)}
      </span>
    </span>
    """
  end

  def winrate_style(winrate) do
    red = 255 - 255 * winrate
    green = 255 * winrate
    blue = min(red, green)
    "background-color: rgb(#{red}, #{green}, #{blue}"
  end
end
