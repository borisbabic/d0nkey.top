defmodule Twitch.TokenRefresher do
  @moduledoc false
  alias Twitch.Token
  use Tesla
  plug Tesla.Middleware.BaseUrl, "https://id.twitch.tv"

  plug Tesla.Middleware.Query,
    client_id: Application.fetch_env!(:backend, :twitch_client_id),
    client_secret: Application.fetch_env!(:backend, :twitch_client_secret),
    grant_type: "client_credentials"

  plug Tesla.Middleware.JSON
  use GenServer
  @name :twitch_token

  def get_token(), do: GenServer.call(@name, :get_token)

  def start_link(default), do: GenServer.start_link(__MODULE__, default, name: @name)

  def init(_args) do
    state =
      fetch_token()
      |> elem(1)

    {:ok, state}
  end

  def handle_info(:update_token, state) do
    {repeat_in, new_state} =
      case fetch_token() do
        {:ok, body} ->
          {1000 * 60 * 60 * Util.to_int_or_orig(body["expires_in"]), body}

        {:error, _} ->
          {1000 * 60, state}
      end

    Process.send_after(self(), :update_token, repeat_in)
    {:noreply, new_state}
  end

  defp fetch_token() do
    with {:ok, %{body: body}} <- post("/oauth2/token", "") do
      {:ok, body |> Token.from_raw_map()}
    else
      _ -> {:error, "Error getting token"}
    end
  end

  def handle_call(:get_token, _from, state = %{access_token: access_token}) do
    {:reply, access_token, state}
  end

  def handle_call(:get_token, _from, state) do
    case fetch_token() do
      {:ok, body} -> {:reply, body.access_token, body}
      {:error, _} -> {:error, "", state}
    end
  end
end
