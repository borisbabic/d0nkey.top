defmodule BackendWeb.StreamingController do
  use BackendWeb, :controller
  @moduledoc false

  def streamers_decks(conn, %{"twitch_login" => twitch_login}) do
    real_route =
      Routes.streaming_path(
        conn,
        :streamer_decks,
        Map.put(conn.query_params, "twitch_login", twitch_login)
      )

    redirect(conn, to: real_route)
  end

  def streamer_decks(conn, params) do
    criteria =
      %{"order_by" => {:desc, :last_played}, "limit" => 30, "offset" => 0} |> Map.merge(params)

    streamer_decks = Backend.Streaming.streamer_decks(criteria)

    render(conn, "streamer_decks.html", %{
      streamer_decks: streamer_decks,
      conn: conn,
      criteria: criteria
    })
  end
end
