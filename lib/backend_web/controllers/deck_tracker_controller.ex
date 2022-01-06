defmodule BackendWeb.DeckTrackerController do
  use BackendWeb, :controller

  @moduledoc """
  Controller for actions performed by a deck tracker
  """

  require Logger
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker

  defp api_user(%{assigns: %{api_user: api_user}}), do: api_user
  defp api_user(_), do: nil
  def put_game(conn, params) do
    api_user = api_user(conn)

    params
    |> log_if_hdt(params)
    |> GameDto.from_raw_map(api_user)
    |> log_if_hdt(params)
    |> DeckTracker.handle_game()
    |> log_if_hdt(params)
    |> case do
      {:ok, _} ->
        conn
        |> put_status(200)
        |> text("Success")

      {:error, :missing_game_id} ->
        conn
        |> put_status(400)
        |> text("Missing game_id")

      {:error, reason} ->
        Logger.warn(
          "Unknown error submitting games reason: #{inspect(reason)} params: #{inspect(params)}"
        )

        conn
        |> put_status(500)
        |> text("Unknown error")
    end
  end

  defp log_if_hdt(to_log, %{"source" => "hdt_plugin"}) do
    Logger.error(inspect(to_log))
    to_log
  end
  defp log_if_hdt(to_log, _), do: to_log
end
