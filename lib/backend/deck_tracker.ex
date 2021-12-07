defmodule Hearthstone.DeckTracker do
  @moduledoc false

  import Ecto.Query
  alias Backend.Repo
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.Enums.Format
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Backend.UserManager
  alias Backend.UserManager.User

  @type deck_stats :: %{deck: Deck.t(), wins: integer(), losses: integer()}

  @spec get_game(integer) :: Game.t() | nil
  def get_game(id), do: Repo.get(Game, id) |> Repo.preload(:player_deck)

  def handle_game(game_dto = %{game_id: game_id}) when is_binary(game_id) do
    attrs =
      GameDto.to_ecto_attrs(game_dto, &handle_deck/1)
      |> set_public()

    case get_existing(game_id) do
      game = %{game_id: ^game_id} -> update_game(game, attrs)
      _ -> create_game(attrs)
    end
  end

  def handle_game(_), do: {:error, :missing_game_id}

  defp set_public(attrs), do: Map.put(attrs, "public", public?(attrs))
  defp public?(%{"player_btag" => btag}) do
    with user = %{twitch_id: twitch_id} <- UserManager.get_by_btag(btag),
                  live <- Twitch.HearthstoneLive.twitch_id_live?(twitch_id) do
        User.replay_public?(user, live)
    else
      _ -> false
    end
  end
  defp public?(_), do: false


  def sum_stats(stats) do
    stats
    |> Enum.reduce(%{losses: 0, wins: 0,  total: 0}, fn s, acc ->
      %{
        wins: s.wins + acc.wins,
        losses: s.losses + acc.losses,
        total: s.total + acc.total
      }
    end)
    |> recalculate_winrate()
  end

  def recalculate_winrate(m = %{wins: wins, total: total}), do: Map.put(m, :winrate, wins/total)

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

  @spec detailed_stats(integer(), list()) :: [deck_stats()]
  def detailed_stats(deck_id, additional_criteria \\ []) when is_integer(deck_id) do
    opponent_class_stats([{"player_deck_id", deck_id} | additional_criteria])
  end

  def total_stats(criteria) do
    base_total_stats_query()
    |> build_games_query(criteria)
    |> Repo.all()
  end
  def class_stats(criteria) do
    base_class_stats_query()
    |> build_games_query(criteria)
    |> Repo.all()
  end
  @doc """
  Stats grouped by opponent's class
  """
  def opponent_class_stats(criteria) do
    base_opponent_class_stats_query()
    |> build_games_query(criteria)
    |> Repo.all()
  end

  defp base_opponent_class_stats_query() do
    base_stats_query()
    |> group_by([g], g.opponent_class)
    |> select_merge([g],
      %{
        opponent_class: g.opponent_class
      }
    )
    |> where([g], not is_nil(g.opponent_class))
  end
  defp base_deck_stats_query() do
    base_stats_query()
    |> group_by([g], g.player_deck_id)
    |> select_merge([g],
      %{
        deck_id: g.player_deck_id
      }
    )
    |> where([g], not is_nil(g.player_deck_id))
  end
  defp base_class_stats_query() do
    base_stats_query()
    |> group_by([g], g.player_class)
    |> select_merge([g],
      %{
        player_class: g.player_class
      }
    )
    |> where([g], not is_nil(g.player_class))
  end
  defp base_total_stats_query() do
    base_stats_query()
  end

  @total_select_pos 3
  @winrate_select_pos 4
  @total_fragment "CASE WHEN ? IN ('win', 'loss') THEN 1 ELSE 0 END"
  defp base_stats_query() do
    from g in Game,
    join: pd in assoc(g, :player_deck),
    select:
      %{
        wins: sum(fragment("CASE WHEN ? = 'win' THEN 1 ELSE 0 END", g.status)),
        losses: sum(fragment("CASE WHEN ? = 'loss' THEN 1 ELSE 0 END", g.status)),
        total: sum(fragment(@total_fragment, g.status)),
        winrate: fragment("cast(SUM(CASE WHEN ? = 'win' THEN 1 ELSE 0 END) as float) / COALESCE(NULLIF(SUM(CASE WHEN ? IN ('win', 'loss') THEN 1 ELSE 0 END), 0), 1)", g.status, g.status)
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

  defp compose_games_query(period, query) when period in [:past_week, :past_day, :past_3_days],
    do: compose_games_query({"period", to_string(period)}, query)

  defp compose_games_query({"period", "past_2_weeks"}, query),
    do: query |> where([g], g.inserted_at >= ago(2, "week"))

  defp compose_games_query({"period", "past_week"}, query),
    do: query |> where([g], g.inserted_at >= ago(1, "week"))

  defp compose_games_query({"period", "past_day"}, query),
    do: query |> where([g], g.inserted_at >= ago(1, "day"))

  defp compose_games_query({"period", "past_3_days"}, query),
    do: query |> where([g], g.inserted_at >= ago(3, "day"))

  defp compose_games_query({"period", "past_30_days"}, query),
    do: query |> where([g], g.inserted_at >= ago(30, "day"))

  defp compose_games_query({"period", "alterac_valley"}, query) do
    av_release = ~N[2021-12-07 18:00:00]
    query |> where([g], g.inserted_at >= ^av_release)
  end

  defp compose_games_query(rank, query) when rank in [:legend, :diamond_to_legend],
    do: compose_games_query({"rank", to_string(rank)}, query)

  defp compose_games_query({"rank", "legend"}, query),
    do: query |> where([g], g.player_rank >= 51)

  defp compose_games_query({"rank", "diamond_to_legend"}, query),
    do: query |> where([g], g.player_rank >= 41)
  defp compose_games_query({"rank", "all"}, query),
    do: query

  defp compose_games_query({"order_by", "latest"}, query),
    do: query |> order_by([g], desc: g.inserted_at)

  defp compose_games_query({"order_by", "total"}, query),
    do: query |> order_by([g], desc: @total_select_pos)

  defp compose_games_query({"order_by", "winrate"}, query),
    do: query |> order_by([], desc: @winrate_select_pos)


  defp compose_games_query(order_by, query) when order_by in [:latest, :winrate, :total],
    do: compose_games_query({"order_by", to_string(order_by)}, query)

  defp compose_games_query({"player_deck_includes", cards}, query),
    do: query |> where([_, pd], fragment("? @> ?", pd.cards, ^cards))

  defp compose_games_query({"player_deck_excludes", cards}, query),
    do: query |> where([_, pd], not(fragment("? @> ?", pd.cards, ^cards)))

  defp compose_games_query({"player_deck_id", deck_id}, query),
    do: query |> where([g], g.player_deck_id == ^deck_id)

  defp compose_games_query({"player_btag", btag}, query),
    do: query |> where([g], g.player_btag == ^btag)

  defp compose_games_query({"player_class", class}, query),
    do: query |> where([g], g.player_class == ^String.upcase(class))

  defp compose_games_query({"player_rank", rank}, query),
    do: query |> where([g], g.player_rank == ^rank)

  defp compose_games_query({"min_games", min_games_string}, query) when is_binary(min_games_string) do
    case Integer.parse(min_games_string) do
      {min, _} -> compose_games_query({"min_games", min}, query)
      _ -> query
    end
  end

  defp compose_games_query({"min_games", min_games}, query),
    do: query |> having([g], sum(fragment(@total_fragment, g.status)) >= ^min_games)

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

  defp compose_games_query(:ranked, query), do: compose_games_query({"game_type", 7}, query)
  defp compose_games_query({"game_type", game_type}, query),
    do: query |> where([g], g.game_type == ^game_type)

  for {id, atom} <- Format.all(:atoms) do
    defp compose_games_query(unquote(atom), query), do: compose_games_query({"format", unquote(id)}, query)
  end

  defp compose_games_query({"format", format}, query),
    do: query |> where([g], g.format == ^format)

  defp compose_games_query({"status", status}, query),
    do: query |> where([g], g.status == ^status)

  defp compose_games_query({"limit", limit}, query), do: query |> limit(^limit)
  defp compose_games_query({"offset", offset}, query), do: query |> offset(^offset)

  def replay_link(%{game_id: game_id}),
    do: "https://replays.firestoneapp.com/?reviewId=#{game_id}"
end
