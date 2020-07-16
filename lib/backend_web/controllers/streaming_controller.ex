defmodule BackendWeb.StreamingController do
  use BackendWeb, :controller
  @moduledoc false

  def streamers_decks(conn, %{"twitch_login" => twitch_login}) do
    decks = Backend.Streaming.get_streamers_decks(twitch_login)
    render(conn, "streamers_decks.html", %{decks: decks})
  end

  def streamer_decks(conn, _params) do
    streamer_decks = Backend.Streaming.get_latest_streamer_decks()
    render(conn, "streamer_decks.html", %{streamer_decks: streamer_decks, conn: conn})
  end
end
