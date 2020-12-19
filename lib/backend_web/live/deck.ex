defmodule BackendWeb.DeckLive do
  @moduledoc false
  alias Components.Decklist
  alias Backend.Hearthstone.Deck
  use Surface.LiveView
  data(deckcode, :string)

  def mount(_params, %{"code" => code}, socket) do
    {:ok, socket |> assign(deckcode: code)}
  end

  def render(assigns) do
    deck = Deck.decode!(assigns[:deckcode])

    ~H"""
    <div class="column is-narrow">
      <Decklist deck={{deck}} />
    </div>
    """
  end
end
