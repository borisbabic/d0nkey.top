defmodule Hearthstone.DeckTracker.InsertListener do
  alias Hearthstone.DeckTracker
  alias Backend.Streaming
  @moduledoc "Listen to inserts"
  use GenServer
  @name :dt_games_insert_listener
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    BackendWeb.Endpoint.subscribe("hs:decktracker:game")
    {:ok, %{}}
  end

  def handle_info(%{topic: "hs:decktracker:game", event: "insert", payload: game}, state) do
    process_game(game)
    {:noreply, state}
  end

  def process_inserted_id(id) do
    with %{id: _} = game <- DeckTracker.get_game(id) do
      process_game(game)
    end
  end

  def process_game(game) do
    with %{id: _} = user <- Backend.UserManager.get_by_btag(game.player_btag),
         {:ok, streamer} <- Streaming.live_streamer_for_user(user) do
      handle_live_dt_game(game, streamer)
    end
  end

  def handle_live_dt_game(game, streamer) do
    with {:ok, streamer_deck} <- Streaming.log_streamer_game(streamer, game) do
      Backend.Streaming.StreamerDeckBag.log(streamer_deck)
    end
  end
end
