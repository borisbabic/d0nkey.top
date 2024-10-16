defmodule BackendWeb.DeckTrackerController do
  use BackendWeb, :controller

  @moduledoc """
  Controller for actions performed by a deck tracker
  """

  require Logger
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.GameInserter

  defp api_user(%{assigns: %{api_user: api_user}}), do: api_user
  defp api_user(_), do: nil

  def put_game(conn, params) do
    api_user = api_user(conn)

    case enqueue_game(params, api_user) do
      {:ok, %Deck{id: _} = deck} ->
        conn
        |> put_status(200)
        |> json(%{
          "player_deck" => Backend.Hearthstone.deck_info(deck)
        })

      {:ok, nil} ->
        conn
        |> put_status(200)
        |> text("Deck missing or not parsable")

      {:ok, _other} ->
        conn
        |> put_status(200)
        |> text("Success")

      {:error, :missing_game_id} ->
        conn
        |> put_status(400)
        |> text("Missing game_id")

      {:error, reason} ->
        Logger.warning(
          "Unknown error submitting games reason: #{inspect(reason)} params: #{inspect(params)}"
        )

        conn
        |> put_status(500)
        |> text("Unknown error")
    end
  end

  @spec enqueue_game(Map.t(), Backend.Api.ApiUser.t()) ::
          {:ok, player_deck :: Deck.t()} | {:error, any()}
  defp enqueue_game(params, api_user) do
    dto = params |> GameDto.from_raw_map(api_user)

    with :ok <- GameDto.validate_game_id(dto),
         {:ok, deck} <- extract_player_deck(dto),
         {:ok, _} <- GameInserter.enqueue(params, api_user) do
      {:ok, deck}
    end
  end

  @spec extract_player_deck(GameDto.t()) :: {:ok, Deck.t()} | {:ok, nil} | {:error, any()}
  defp extract_player_deck(%{player: %{deckcode: code}}) when is_binary(code) do
    Backend.Hearthstone.create_or_get_deck(code)
  end

  defp extract_player_deck(_), do: {:ok, nil}

  # def put_game(conn, params) do
  #   api_user = api_user(conn)

  #   params
  #   |> GameDto.from_raw_map(api_user)
  #   |> log_game(params)
  #   |> DeckTracker.handle_game()
  #   |> case do
  #     {:ok, %{player_deck: pd = %{id: _}}} ->
  #       conn
  #       |> put_status(200)
  #       |> json(%{
  #         "player_deck" => Backend.Hearthstone.deck_info(pd)
  #       })

  #     {:ok, _other} ->
  #       conn
  #       |> put_status(200)
  #       |> text("Success")

  #     {:error, :missing_game_id} ->
  #       conn
  #       |> put_status(400)
  #       |> text("Missing game_id")

  #     {:error, reason} ->
  #       Logger.warning(
  #         "Unknown error submitting games reason: #{inspect(reason)} params: #{inspect(params)}"
  #       )

  #       conn
  #       |> put_status(500)
  #       |> text("Unknown error")
  #   end
  # end

  defp log_game(dto = %{player: %{battletag: "D0nkey#2470"}}, params),
    do: log_game(:error, dto, params)

  defp log_game(dto, params), do: log_game(:debug, dto, params)

  defp log_game(level, dto, params) do
    Logger.log(level, "params: #{inspect(params)}")
    Logger.log(level, "dto: #{inspect(dto)}")
    dto
  end

  def hdt_plugin_latest_version(conn, _params) do
    case Application.get_env(:backend, :hdt_plugin_latest_version, nil) do
      nil -> conn |> put_status(500) |> text("No latest version")
      ver -> conn |> put_status(200) |> text(ver)
    end
  end

  def hdt_plugin_latest_file(conn, _params) do
    case Application.get_env(:backend, :hdt_plugin_latest_file, nil) do
      path when is_binary(path) -> conn |> send_file(200, path)
      nil -> conn |> put_status(500) |> text("No latest version")
    end
  end
end
