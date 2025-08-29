defmodule BackendWeb.DeckTrackerController do
  use BackendWeb, :controller

  @moduledoc """
  Controller for actions performed by a deck tracker
  """

  require Logger
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.GameInsertBatcher

  defp api_user(%{assigns: %{api_user: api_user}}), do: api_user
  defp api_user(_), do: nil

  def post_collection(conn, params) do
    Backend.CollectionManager.CollectionUpdater.enqueue(params)

    conn
    |> put_status(200)
    |> json(%{"result" => "success"})
  end

  def put_game(conn, params) do
    api_user = api_user(conn)

    case enqueue_game(params, api_user) do
      {:ok, %{deck: %Deck{} = deck} = ret} ->
        conn
        |> put_status(200)
        |> json(%{
          "player_deck" => Backend.Hearthstone.deck_info(deck),
          "player_archetype" => Map.get(ret, :player_archetype),
          "opponent_archetype" => Map.get(ret, :opponent_archetype)
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
    dto =
      params
      |> GameDto.from_raw_map(api_user)
      |> log_game(params)

    with :ok <- GameDto.validate_game_id(dto),
         {:ok, deck} <- extract_player_deck(dto) do
      with_inserted_at =
        Map.put(params, "inserted_at", NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601())

      GameInsertBatcher.enqueue(with_inserted_at, api_user)
      {player_archetype, opponent_archetype} = extract_played_archetypes(dto)

      {:ok,
       %{deck: deck, player_archetype: player_archetype, opponent_archetype: opponent_archetype}}
    end
  end

  defp extract_played_archetypes(%{format: format} = game_dto) when is_integer(format) do
    player_played =
      get_in(game_dto, [Access.key(:player, %{}), Access.key(:cards_played, [])]) || []

    opponent_played =
      get_in(game_dto, [Access.key(:opponent, %{}), Access.key(:cards_played, [])]) || []

    player_class = Map.get(game_dto, :player_class, nil)
    opponent_class = Map.get(game_dto, :opponent_class, nil)

    player_archetype =
      Backend.PlayedCardsArchetyper.archetype(player_played, player_class, format)

    opponent_archetype =
      Backend.PlayedCardsArchetyper.archetype(opponent_played, opponent_class, format)

    {player_archetype, opponent_archetype}
  end

  defp extract_played_archetypes(_), do: {nil, nil}
  @spec extract_player_deck(GameDto.t()) :: {:ok, Deck.t()} | {:ok, nil} | {:error, any()}
  defp extract_player_deck(%{player: %{deckcode: code}}) when is_binary(code) do
    Deck.decode(code)
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
