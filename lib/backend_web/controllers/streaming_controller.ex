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

  defp add_archetypes_filter(criteria_map, archetypes),
    do: criteria_map |> Map.put("hsreplay_archetype", archetypes)

  def streamer_decks(conn, params) do
    cards =
      multi_select_to_array(params["cards"])
      |> Enum.map(&Util.to_int_or_orig/1)

    archetypes =
      multi_select_to_array(params["hsreplay_archetypes"])
      |> Enum.map(&Util.to_int_or_orig/1)

    criteria =
      %{"order_by" => {:desc, :last_played}, "limit" => 50, "offset" => 0}
      |> Map.merge(params)
      |> Map.put("cards", cards)
      |> add_archetypes_filter(archetypes)

    streamer_decks = Backend.Streaming.streamer_decks(criteria)
    streamers = Backend.Streaming.streamers(%{"order_by" => {:asc, :hsreplay_twitch_display}})

    page_title =
      case params["twitch_login"] do
        nil -> "Streamer decks"
        tl -> "#{tl}'s decks"
      end

    render(conn, "streamer_decks.html", %{
      streamer_decks: streamer_decks,
      conn: conn,
      streamers: streamers,
      archetypes: archetypes,
      page_title: page_title,
      cards: cards,
      criteria: criteria
    })
  end
end
