defmodule Hearthstone.DeckTracker do
  @moduledoc false

  import Ecto.Query
  alias Backend.Repo
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.Game
  alias Backend.Hearthstone

  @spec get_game(integer) :: Game.t() | nil
  def get_game(id), do: Repo.get(Game, id) |> Repo.preload(:player_deck)

  def handle_game(game_dto = %{game_id: game_id}) when is_binary(game_id) do
    attrs = GameDto.to_ecto_attrs(game_dto, &handle_deck/1)

    case get_existing(game_id) do
      game = %{game_id: ^game_id} -> update_game(game, attrs)
      _ -> create_game(attrs)
    end
  end

  def handle_game(_), do: {:error, :missing_game_id}

  defp handle_deck(code) when is_binary(code), do: Hearthstone.create_or_get_deck(code)
  defp handle_deck(nil), do: {:ok, nil}

  defp get_existing(game_id) do
    query =
      from g in Game,
        where: g.game_id == ^game_id

    Repo.one(query)
  end

  defp update_game(game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  defp create_game(attrs) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end
end
