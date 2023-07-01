defmodule BackendWeb.DeckControllerTest do
  use BackendWeb.ConnCase

  @even_shaman "AAEBAaoIBDPWD830ArHZBA2+BpTvAp2jA9qlA/mRBPq0BLLBBIbUBKrZBL3lBPTyBcGeBtCeBgA="
  @invalid_code "blabla"

  test "post valid deck", %{conn: conn} do
    conn = post(conn, "/api/deck-info", %{"decks" => [@even_shaman]})

    body = json_response(conn, 200)
    assert %{"name" => "Even Shaman", "archetype" => "Even Shaman"} = body[@even_shaman]
  end

  test "post ignores invalid decks", %{conn: conn} do
    conn = post(conn, "/api/deck-info", %{"decks" => [@even_shaman, @invalid_code]})

    body = json_response(conn, 200)
    assert %{"name" => "Even Shaman", "archetype" => "Even Shaman"} = body[@even_shaman]
  end

  test "get valid deck", %{conn: conn} do
    conn = get(conn, "/api/deck-info/#{@even_shaman}")

    body = json_response(conn, 200)
    assert %{"name" => "Even Shaman", "archetype" => "Even Shaman"} = body
  end

  test "get invalid deck", %{conn: conn} do
    conn = get(conn, "/api/deck-info/#{@invalid_code}")

    assert text_response(conn, 400)
  end
end
