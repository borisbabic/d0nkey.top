defmodule Hearthstone.DeckTracker.InsertListener do
  alias Hearthstone.DeckTracker
  @moduledoc "Listen to inserts"
  use GenServer
  @name :dt_games_insert_listener
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    BackendWeb.Endpoint.subscribe("entity_dt_games")
    {:ok, %{}}
  end

  def handle_info(%{event: "insert", topic: "entity_dt_games", payload: %{id: id}}, state) do
    process_inserted_id(id)
    {:noreply, state}
  end

  def process_inserted_id(id) do
    with game = %{id: _} <- DeckTracker.get_game(id),
         %{twitch_id: twitch_id} when is_binary(twitch_id) <-
           Backend.UserManager.get_by_btag(game.player_btag),
         true <- Twitch.HearthstoneLive.twitch_id_live?(twitch_id) do
      handle_live_dt_game(game, twitch_id)
    end
  end

  def handle_live_dt_game(game, twitch_id) do
    Backend.Streaming.log_streamer_game(twitch_id, game)
  end
end
