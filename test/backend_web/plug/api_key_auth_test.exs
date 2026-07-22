defmodule BackendWeb.Plug.ApiKeyAuthTest do
  use BackendWeb.ConnCase

  alias BackendWeb.Plug.ApiKeyAuth

  setup do
    user = create_temp_user()
    {:ok, %{api_key: api_key, token: token}} = Backend.Api.create_developer_api_key(user)

    %{api_key: api_key, token: token, user: user}
  end

  test "authenticates a bearer API key", %{conn: conn, api_key: api_key, token: token, user: user} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> ApiKeyAuth.call([])

    refute conn.halted
    assert conn.assigns.developer_api_key.id == api_key.id
    assert conn.assigns.developer_api_user.id == user.id
  end

  test "accepts a case-insensitive bearer scheme", %{conn: conn, api_key: api_key, token: token} do
    conn =
      conn
      |> put_req_header("authorization", "bearer #{token}")
      |> ApiKeyAuth.call([])

    refute conn.halted
    assert conn.assigns.developer_api_key.id == api_key.id
  end

  test "authenticates an x-api-key header", %{conn: conn, api_key: api_key, token: token} do
    conn =
      conn
      |> put_req_header("x-api-key", token)
      |> ApiKeyAuth.call([])

    refute conn.halted
    assert conn.assigns.developer_api_key.id == api_key.id
  end

  test "returns JSON 401 for an invalid key", %{conn: conn} do
    conn =
      conn
      |> put_req_header("x-api-key", "hsg_live_invalid.invalid")
      |> ApiKeyAuth.call([])

    assert conn.halted
    assert conn.status == 401
    assert %{"error" => %{"code" => "invalid_api_key"}} = Jason.decode!(conn.resp_body)
  end

  test "returns JSON 401 for a revoked key", %{conn: conn, token: token, user: user} do
    :ok = Backend.Api.revoke_developer_api_key(user)

    conn = conn |> put_req_header("x-api-key", token) |> ApiKeyAuth.call([])

    assert conn.halted
    assert conn.status == 401
  end
end
