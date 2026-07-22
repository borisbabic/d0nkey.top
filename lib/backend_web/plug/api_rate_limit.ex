defmodule BackendWeb.Plug.ApiRateLimit do
  @moduledoc "Applies the configured per-key limit to developer API requests."

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias Backend.Api.RateLimiter

  @default_limit 60
  @default_window_ms :timer.minutes(1)

  def init(opts), do: opts

  def call(%{assigns: %{developer_api_key: api_key}} = conn, opts) do
    config = Application.get_env(:backend, :developer_api, [])
    limit = Keyword.get(opts, :limit, Keyword.get(config, :rate_limit, @default_limit))
    window_ms = Keyword.get(opts, :window_ms, Keyword.get(config, :window_ms, @default_window_ms))

    case RateLimiter.hit(api_key.id, limit, window_ms) do
      {:allow, remaining, reset_after_ms} ->
        put_rate_limit_headers(conn, limit, remaining, reset_after_ms)

      {:deny, retry_after_ms} ->
        retry_after = milliseconds_to_seconds(retry_after_ms)

        conn
        |> put_rate_limit_headers(limit, 0, retry_after_ms)
        |> put_resp_header("retry-after", to_string(retry_after))
        |> put_status(:too_many_requests)
        |> json(%{
          error: %{
            code: "rate_limit_exceeded",
            message: "Rate limit exceeded",
            retry_after: retry_after
          }
        })
        |> halt()
    end
  end

  def call(conn, _opts), do: conn

  defp put_rate_limit_headers(conn, limit, remaining, reset_after_ms) do
    conn
    |> put_resp_header("x-ratelimit-limit", to_string(limit))
    |> put_resp_header("x-ratelimit-remaining", to_string(remaining))
    |> put_resp_header("x-ratelimit-reset", to_string(milliseconds_to_seconds(reset_after_ms)))
  end

  defp milliseconds_to_seconds(milliseconds) do
    ceil(milliseconds / 1000)
  end
end
