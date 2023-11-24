defmodule Components.DeckStats do
  @moduledoc false
  use Surface.Component
  alias Components.WinrateTag
  prop(total, :number, required: false)
  prop(winrate, :number, required: false)
  prop(element_class, :css_class, default: "")

  def render(assigns) do
    ~F"""
      <WinrateTag :if={@winrate} class={"column"} winrate={@winrate} round_digits={1}/>
      <div :if={@total} class="column tag">
        Games: {@total}
      </div>
    """
  end

  def round_winrate(val) when is_float(val), do: Float.round(val * 100, 1)
  def round_winrate(val), do: val
  # def winrate_style(winrate), do: Components.WinrateTag.winrate_style(winrate)
end
