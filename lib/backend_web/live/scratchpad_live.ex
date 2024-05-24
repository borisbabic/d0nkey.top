defmodule BackendWeb.ScratchPadLive do
  use BackendWeb, :surface_live_view_no_layout
  alias Components.ClippedCard

  def render(assigns) do
    ~F"""
      <div class="h2">Don't be naughty</div>
      <div class="">
        <div class="">
          <div :for={card <- cards()} class="">
            <ClippedCard  card={card}/>
          </div>
        </div>
      </div>
    """
  end

  defp cards() do
    Backend.Hearthstone.get_deck(11_100_865)
    |> Map.get(:cards)
    |> Enum.uniq()
    |> Enum.map(&Backend.Hearthstone.get_card/1)
  end
end
