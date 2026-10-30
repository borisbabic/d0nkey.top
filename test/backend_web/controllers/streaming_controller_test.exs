defmodule BackendWeb.StreamingControllerTest do
  use BackendWeb.ConnCase

  test "GET /streamer-decks doesn't include uncollectible cards in the dropdown", %{conn: conn} do
    url = Routes.streaming_path(conn, :streamer_decks)
    conn = get(conn, url)
    assert html_response(conn, 200)
    refute html_response(conn, 200) =~ "Assistant Bigglesworth"
  end

  test "GET /streamer-decks filters by youtube channel", %{conn: conn} do
    {:ok, streamer} =
      Backend.Streaming.upsert_youtube_streamer("UC_controller", %{youtube_display: "YT Controller"})

    {:ok, deck} =
      Backend.Hearthstone.create_or_get_deck(
        "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      )

    {:ok, _} =
      Backend.Streaming.create_streamer_deck(
        deck,
        streamer,
        Backend.Streaming.StreamerDeckInfoDto.create(0, 5, 7)
      )

    html =
      conn
      |> get(Routes.streaming_path(conn, :streamer_decks, %{"youtube_channel_id" => "UC_controller"}))
      |> html_response(200)

    assert html =~ "YT Controller"
    assert html =~ "https://www.youtube.com/channel/UC_controller"
  end
end
