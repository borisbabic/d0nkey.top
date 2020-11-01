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
    cards =
      multi_select_to_array(params["cards"])
      |> Enum.map(&Util.to_int_or_orig/1)

    archetypes =
      multi_select_to_array(params["archetypes"])
      |> Enum.map(&Util.to_int_or_orig/1)

    criteria =
      %{"order_by" => {:desc, :last_played}, "limit" => 50, "offset" => 0}
      |> Map.merge(params)
      |> Map.put("cards", cards)

    streamer_decks = Backend.Streaming.streamer_decks(criteria)
    streamers = Backend.Streaming.streamers(%{"order_by" => {:asc, :twitch_display}})

    render(conn, "streamer_decks.html", %{
      streamer_decks: streamer_decks,
      conn: conn,
      streamers: streamers,
      archetypes: archetypes,
      cards: cards,
      criteria: criteria
    })
  end
end
