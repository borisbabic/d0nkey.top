defmodule BackendWeb.DeckLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Components.DeckStreamingInfo
  alias Components.Decklist

  data(deck, :any)
  data(streamer_decks, :any)

  def handle_params(params = %{"deck" => deck_parts}, session, socket) when is_list(deck_parts) do
    new_deck = deck_parts |> Enum.join("/")

    params
    |> Map.put("deck", new_deck)
    |> handle_params(session, socket)
  end

  def handle_params(%{"deck" => deck}, _session, socket) do
    deck =
      with :error <- Integer.parse(deck),
           {:ok, deck} <- Deck.decode(deck) do
        Hearthstone.deck(deck) || deck
      else
        {deck_id, _} when is_integer(deck_id) -> Hearthstone.deck(deck_id)
        _ -> []
      end

    {:noreply, socket |> assign(deck: deck)}
  end

  def render(assigns = %{deck: _}) do
    ~H"""
    <div class="container">
      <br>
      <div class="columns is-narrow is-mobile is-multiline">
        <div class="column">
          <Decklist deck={{ @deck }}/>
        </div>
        <div class="column" :if={{ @deck.id }}>
          <DeckStreamingInfo deck_id={{ @deck.id }}/>
        </div>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <h2>Whooops</h2>
    Invalid deck, please go back, queue wild, or try again
    """
  end
end
