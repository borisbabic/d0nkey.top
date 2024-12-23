defmodule Components.DeckStats do
  @moduledoc false
  use Surface.Component
  alias Components.WinrateTag
  prop(total, :number, required: false)
  prop(winrate, :number, required: false)
  prop(element_class, :css_class, default: "")
  prop(win_loss, :any, default: nil)

  def render(assigns) do
    ~F"""
      <WinrateTag :if={@winrate} class={"column"} winrate={@winrate} win_loss={@win_loss}/>
      <div :if={@total} class="column tag">
        Games: {@total}
      </div>
    """
  end

  def round_winrate(val) when is_float(val), do: Float.round(val * 100, 1)
  def round_winrate(val), do: val
  # def winrate_style(winrate), do: Components.WinrateTag.winrate_style(winrate)
end
