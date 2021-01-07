defmodule BackendWeb.ExpandableDeckLive do
  @moduledoc false
  alias Components.Decklist
  alias Backend.Hearthstone.Deck
  use Surface.LiveView
  data(deckcode, :string)
  data(name, :string)
  data(show_cards, :boolean)

  def mount(_params, p = %{"code" => code}, socket) do
    {:ok, socket |> assign(deckcode: code, show_cards: !!p["show_cards"], name: p["name"])}
  end

  def render(assigns) do
    deck = Deck.decode!(assigns[:deckcode])

    ~H"""
    <div class="column is-narrow">
      <Decklist deck={{deck}} show_cards={{ @show_cards }} name={{ @name }}>
        <template slot="right_button">
          <span phx-click="show_cards" class="is-clickable" >
            <span class="icon">
              <i :if={{ !@show_cards }} class="fas fa-eye"></i>
              <i :if={{ @show_cards }} class="fas fa-eye-slash"></i>
            </span>
          </span>
        </template>
      </Decklist>
    </div>
    """
  end

  def handle_event("show_cards", _, socket = %{assigns: %{show_cards: old}}) do
    {
      :noreply,
      socket
      |> assign(show_cards: !old)
    }
  end
end
