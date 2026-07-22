defmodule BackendWeb.Plug.ApiRateLimitTest do
  use BackendWeb.ConnCase

  alias BackendWeb.Plug.ApiRateLimit

  test "returns rate headers and rejects requests over the limit", %{conn: conn} do
    api_key = %{id: System.unique_integer([:positive])}
    opts = [limit: 1, window_ms: 60_000]

    allowed = conn |> assign(:developer_api_key, api_key) |> ApiRateLimit.call(opts)

    refute allowed.halted
    assert get_resp_header(allowed, "x-ratelimit-limit") == ["1"]
    assert get_resp_header(allowed, "x-ratelimit-remaining") == ["0"]

    denied = build_conn() |> assign(:developer_api_key, api_key) |> ApiRateLimit.call(opts)

    assert denied.halted
    assert denied.status == 429
    assert get_resp_header(denied, "retry-after") != []
    assert %{"error" => %{"code" => "rate_limit_exceeded"}} = Jason.decode!(denied.resp_body)
  end
end
