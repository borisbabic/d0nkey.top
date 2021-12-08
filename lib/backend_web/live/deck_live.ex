defmodule BackendWeb.DeckLive do
  @moduledoc false
  use Surface.LiveView
  import BackendWeb.LiveHelpers
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Components.DeckStreamingInfo
  alias Components.Decklist
  alias Components.DeckCard
  alias Components.DeckStatsTable

  data(deck, :any)
  data(streamer_decks, :any)
  data(user, :any)
  data(deck_stats_params, :map)

  def mount(_, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end

  def handle_params(params = %{"deck" => deck_parts}, session, socket) when is_list(deck_parts) do
    new_deck = deck_parts |> Enum.join("/")

    params
    |> Map.put("deck", new_deck)
    |> handle_params(session, socket)
  end

  def handle_params(params = %{"deck" => deck}, _session, socket) do
    deck =
      with :error <- Integer.parse(deck),
           {:ok, deck} <- Deck.decode(deck) do
        Hearthstone.deck(deck) || deck
      else
        {deck_id, _} when is_integer(deck_id) -> Hearthstone.deck(deck_id)
        _ -> []
      end

    deck_stats_params = params |> Map.take(DeckStatsTable.param_keys())

    {:noreply, socket |> assign(deck: deck) |> assign_meta() |> assign(:deck_stats_params, deck_stats_params)}
  end

  def render(assigns = %{deck: _}) do
    ~F"""
    <Context put={user: @user}>
      <div class="container">
        <br>
        <div class="columns is-multiline is-mobile is-narrow is-centered">
          <div class="column is-narrow-mobile">
            <DeckCard>
              <Decklist deck={@deck} archetype_as_name={true} />
              <:after_deck>
                <DeckStreamingInfo deck_id={@deck.id}/>
              </:after_deck>
            </DeckCard>
          </div>
          <div class="column is-narrow-mobile">
            <DeckStatsTable id="deck_stats" deck_id={@deck.id} live_view={__MODULE__} path_params={[to_string(@deck.id)]} params={@deck_stats_params} />
          </div>
        </div>
      </div>
    </Context>
    """
  end

  def render(assigns) do
    ~F"""
    <h2>Whooops</h2>
    Invalid deck, please go back, queue wild, or try again
    """
  end

  def assign_meta(socket = %{assigns: %{deck: deck}}) do
    socket
    |> assign_meta_tags(%{
      description: deck |> Deck.deckcode(),
      title: deck.class |> Deck.class_name()
    })
  end
end
