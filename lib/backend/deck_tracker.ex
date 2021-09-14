defmodule Hearthstone.DeckTracker do
  @moduledoc false

  import Ecto.Query
  alias Backend.Repo
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.Game
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  @type deck_stats :: %{deck: Deck.t(), wins: integer(), losses: integer()}

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

  @spec deck_stats(integer(), list()) :: [deck_stats()]
  def deck_stats(deck_id, additional_criteria) do
    deck_stats([{"player_deck_id", deck_id} | additional_criteria])
  end

  @spec deck_stats(integer() | list()) :: [deck_stats()]
  def deck_stats(deck_id) when is_integer(deck_id) do
    deck_stats(deck_id, [])
  end

  def deck_stats(criteria) do
    base_deck_stats_query()
    |> build_games_query(criteria)
    |> Repo.all()
  end

  defp base_deck_stats_query() do
    from g in Game,
      join: pd in assoc(g, :player_deck),
      group_by: pd.id,
      select: %{
        deck: pd,
        wins: sum(fragment("CASE WHEN ? = 'win' THEN 1 ELSE 0 END", g.status)),
        losses: sum(fragment("CASE WHEN ? = 'loss' THEN 1 ELSE 0 END", g.status))
      }
  end

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

  def games(criteria) do
    base_games_query()
    |> build_games_query(criteria)
    |> Repo.all()
  end

  defp base_games_query() do
    from g in Game,
      join: pd in assoc(g, :player_deck),
      preload: [player_deck: pd]
  end

  defp build_games_query(query, criteria),
    do: Enum.reduce(criteria, query, &compose_games_query/2)

  defp compose_games_query(:past_week, query),
    do: query |> where([g], g.inserted_at >= ago(1, "week"))

  defp compose_games_query(:past_day, query),
    do: query |> where([g], g.inserted_at >= ago(1, "day"))

  defp compose_games_query(:past_3_days, query),
    do: query |> where([g], g.inserted_at >= ago(3, "day"))

  defp compose_games_query(:legend, query),
    do: query |> where([g], g.player_rank >= 51)

  defp compose_games_query(:diamond_to_legend, query),
    do: query |> where([g], g.player_rank >= 41)

  defp compose_games_query(:latest, query),
    do: query |> order_by([g], desc: g.inserted_at)

  defp compose_games_query({"player_deck_id", deck_id}, query),
    do: query |> where([g], g.player_deck_id == ^deck_id)

  defp compose_games_query({"player_btag", btag}, query),
    do: query |> where([g], g.player_btag == ^btag)

  defp compose_games_query({"player_class", class}, query),
    do: query |> where([g], g.player_class == ^String.upcase(class))

  defp compose_games_query({"player_rank", rank}, query),
    do: query |> where([g], g.player_rank == ^rank)

  defp compose_games_query({"player_legend_rank", legend_rank}, query),
    do: query |> where([g], g.player_legend_rank == ^legend_rank)

  defp compose_games_query({"opponent_class", class}, query),
    do: query |> where([g], g.opponent_class == ^String.upcase(class))

  defp compose_games_query({"opponent_rank", rank}, query),
    do: query |> where([g], g.opponent_rank == ^rank)

  defp compose_games_query({"opponent_legend_rank", legend_rank}, query),
    do: query |> where([g], g.opponent_legend_rank == ^legend_rank)

  defp compose_games_query({"opponent_btag_like", btag}, query),
    do: query |> where([g], ilike(g.opponent_btag, ^"%#{btag}%"))

  defp compose_games_query({"turns", turns}, query),
    do: query |> where([g], g.turns == ^turns)

  defp compose_games_query({"duration", duration}, query),
    do: query |> where([g], g.duration == ^duration)

  defp compose_games_query({"region", region}, query),
    do: query |> where([g], g.region == ^region)

  defp compose_games_query({"game_type", game_type}, query),
    do: query |> where([g], g.game_type == ^game_type)

  defp compose_games_query({"format", format}, query),
    do: query |> where([g], g.format == ^format)

  defp compose_games_query({"status", status}, query),
    do: query |> where([g], g.status == ^status)

  defp compose_games_query({"limit", limit}, query), do: query |> limit(^limit)
  defp compose_games_query({"offset", offset}, query), do: query |> offset(^offset)

  def replay_link(%{game_id: game_id}),
    do: "https://replays.firestoneapp.com/?reviewId=#{game_id}"
end
