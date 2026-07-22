defmodule BackendWeb.Plug.ApiKeyAuth do
  @moduledoc "Authenticates developer API requests with a user-owned API key."

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, api_key} <- fetch_api_key(conn),
         {:ok, developer_api_key} <- Backend.Api.verify_developer_api_key(api_key) do
      conn
      |> assign(:developer_api_key, developer_api_key)
      |> assign(:developer_api_user, developer_api_key.user)
    else
      _ -> unauthorized(conn)
    end
  end

  defp fetch_api_key(conn) do
    case get_req_header(conn, "authorization") do
      [authorization] -> parse_bearer_token(authorization, conn)
      _ -> fetch_api_key_header(conn)
    end
  end

  defp parse_bearer_token(authorization, conn) do
    case Regex.run(~r/^Bearer\s+(.+)$/i, authorization, capture: :all_but_first) do
      [api_key] -> {:ok, String.trim(api_key)}
      _ -> fetch_api_key_header(conn)
    end
  end

  defp fetch_api_key_header(conn) do
    case get_req_header(conn, "x-api-key") do
      [api_key] when api_key != "" -> {:ok, api_key}
      _ -> {:error, :missing_api_key}
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: %{code: "invalid_api_key", message: "A valid API key is required"}})
    |> halt()
  end
end
