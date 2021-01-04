defmodule BackendWeb.StreamingControllerTest do
  use BackendWeb.ConnCase

  test "GET /streamer-decks doesn't include uncollectible cards in the dropdown", %{conn: conn} do
    url = Routes.streaming_path(conn, :streamer_decks)
    conn = get(conn, url)
    assert html_response(conn, 200)
    refute html_response(conn, 200) =~ "Assistant Bigglesworth"
  end
end
