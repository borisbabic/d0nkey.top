defmodule Hearthstone.DeckTracker do
  @moduledoc false

  import Ecto.Query
  alias Backend.Repo
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.DeckTracker.Source
  alias Hearthstone.Enums.Format
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Backend.UserManager
  alias Backend.UserManager.User
  alias Backend.UserManager.GroupMembership

  @type deck_stats :: %{deck: Deck.t(), wins: integer(), losses: integer()}

  @spec get_game(integer) :: Game.t() | nil
  def get_game(id), do: Repo.get(Game, id) |> Repo.preload(:player_deck)

  @spec get_game_by_game_id(String.t()) :: Game.t() | nil
  def get_game_by_game_id(game_id) do
    query =
      from g in Game,
        preload: [:player_deck, :source],
        where: g.game_id == ^game_id

    Repo.one(query)
  end

  def convert_rank(num) when is_integer(num) do
    rank = 10 - rem(num - 1, 10)

    case div(num - 1, 10) do
      0 -> {:Bronze, rank}
      1 -> {:Silver, rank}
      2 -> {:Gold, rank}
      3 -> {:Platinum, rank}
      4 -> {:Diamond, rank}
      5 -> :Legend
      _ -> :Unknown
    end
  end

  def convert_rank(:Legend), do: 51

  def convert_rank({:Legend, _}), do: 51
  def convert_rank({_, nil}), do: nil

  def convert_rank({level, rank}) when is_atom(level) and is_integer(rank) do
    level_part =
      10 *
        case level do
          :Bronze -> 0
          :Silver -> 1
          :Gold -> 2
          :Platinum -> 3
          :Diamond -> 4
        end

    level_part - rank + 11
  end

  def convert_rank(nil), do: nil

  def handle_self_report(game_dto) do
  end

  def handle_game(game_dto = %{game_id: game_id}) when is_binary(game_id) do
    attrs =
      GameDto.to_ecto_attrs(game_dto, &handle_deck/1, &get_or_create_source/2)
      |> set_public()

    with nil <- get_existing(game_id),
         nil <- get_same_game(attrs) do
      create_game(attrs)
    else
      game = %{game_id: ^game_id} -> update_game(game, attrs)
      # different deck tracker so don't update
      game = %{game_id: _game_id} -> {:ok, game}
      _ -> create_game(attrs)
    end
  end

  def handle_game(_), do: {:error, :missing_game_id}

  defp get_same_game(attrs) do
    query =
      from g in Game,
        as: :game,
        where: g.inserted_at > ago(90, "second")

    query
    |> equals(:player_btag, attrs["player_btag"])
    |> equals(:player_class, attrs["player_class"])
    |> equals(:opponent_class, attrs["opponent_class"])
    |> equals(:opponent_btag, attrs["opponent_btag"])
    |> equals(:format, attrs["format"])
    |> equals(:game_type, attrs["game_type"])
    |> limit(1)
    |> Repo.one()
  end

  defp equals(query, column, nil) do
    query
    |> where([game: g], is_nil(field(g, ^column)))
  end

  defp equals(query, column, value) do
    query
    |> where([game: g], field(g, ^column) == ^value)
  end

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
    |> Enum.reduce(%{losses: 0, wins: 0, total: 0}, fn s, acc ->
      %{
        wins: s.wins + acc.wins,
        losses: s.losses + acc.losses,
        total: s.total + acc.total
      }
    end)
    |> recalculate_winrate()
  end

  def recalculate_winrate(m = %{total: 0}), do: Map.put(m, :winrate, 0.0)
  def recalculate_winrate(m = %{wins: wins, total: total}), do: Map.put(m, :winrate, wins / total)

  @spec deck_stats(integer(), list()) :: [deck_stats()]
  def deck_stats(deck_id, additional_criteria) do
    deck_stats([{"player_deck_id", deck_id} | additional_criteria])
  end

  @spec deck_stats(integer() | list() | Map.t()) :: [deck_stats()]
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

  def archetype_stats(criteria) do
    base_archetype_stats_query()
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
    |> group_by([game: g], g.opponent_class)
    |> select_merge(
      [game: g],
      %{
        opponent_class: g.opponent_class
      }
    )
    |> where([game: g], not is_nil(g.opponent_class))
  end

  defp base_archetype_stats_query() do
    base_stats_query()
    |> group_by([player_deck: pd], pd.archetype)
    |> select_merge(
      [player_deck: pd],
      %{
        archetype: pd.archetype
      }
    )
    |> where([player_deck: pd], not is_nil(pd.archetype))
  end

  defp base_deck_stats_query() do
    base_stats_query()
    |> group_by([game: g], g.player_deck_id)
    |> select_merge(
      [game: g],
      %{
        deck_id: g.player_deck_id
      }
    )
    |> where([game: g], not is_nil(g.player_deck_id))
  end

  defp base_class_stats_query() do
    base_stats_query()
    |> group_by([game: g], g.player_class)
    |> select_merge(
      [game: g],
      %{
        player_class: g.player_class
      }
    )
    |> where([game: g], not is_nil(g.player_class))
  end

  defp base_total_stats_query() do
    base_stats_query()
  end

  @total_select_pos 3
  @winrate_select_pos 4
  @total_fragment "CASE WHEN ? IN ('win', 'loss') THEN 1 ELSE 0 END"
  defp base_stats_query() do
    from g in Game,
      as: :game,
      join: pd in assoc(g, :player_deck),
      as: :player_deck,
      select: %{
        wins: sum(fragment("CASE WHEN ? = 'win' THEN 1 ELSE 0 END", g.status)),
        losses: sum(fragment("CASE WHEN ? = 'loss' THEN 1 ELSE 0 END", g.status)),
        total: sum(fragment(@total_fragment, g.status)),
        winrate:
          fragment(
            "cast(SUM(CASE WHEN ? = 'win' THEN 1 ELSE 0 END) as float) / COALESCE(NULLIF(SUM(CASE WHEN ? IN ('win', 'loss') THEN 1 ELSE 0 END), 0), 1)",
            g.status,
            g.status
          )
      }
  end

  def get_or_create_source(source, version) when is_binary(source) and is_binary(version) do
    with {:ok, nil} <- {:ok, get_source(source, version)},
         {:error, %{errors: [%{source: {_, [constraint: :unique]}}]}} <-
           create_source(source, version),
         {:ok, nil} <- {:ok, get_source(source, version)} do
      {:error, :could_not_get_or_create_deck}
    end
  end

  def get_or_create_source(_, _), do: {:error, :invalid_arguments}

  def create_source(source, version) do
    %Source{}
    |> Source.changeset(%{source: source, version: version})
    |> Repo.insert()
  end

  def get_source(source, version) when is_binary(source) and is_binary(version) do
    query =
      from s in Source,
        where: s.source == ^source and s.version == ^version

    Repo.one(query)
  end

  def get_source(_, _), do: nil
  defp handle_deck(code) when is_binary(code), do: Hearthstone.create_or_get_deck(code)
  defp handle_deck(nil), do: {:ok, nil}

  defp get_existing(game_id) do
    query =
      from g in Game,
        as: :game,
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

  @spec archetypes(list()) :: [atom()]
  def archetypes(raw_criteria) do
    criteria =
      Enum.reject(raw_criteria, fn crit ->
        case crit do
          {"order_by", _} -> true
          {"min_games", _} -> true
          {"archetype", _} -> true
          _ -> false
        end
      end)

    base_archetypes_query()
    |> build_games_query(criteria)
    |> Repo.all()
  end

  defp base_archetypes_query(),
    do:
      from(pd in Deck,
        as: :player_deck,
        inner_join: g in Game,
        on: g.player_deck_id == pd.id,
        as: :game,
        select: pd.archetype,
        distinct: pd.archetype,
        where: not is_nil(pd.archetype)
      )

  defp base_games_query() do
    from g in Game,
      as: :game,
      left_join: pd in assoc(g, :player_deck),
      as: :player_deck,
      preload: [player_deck: pd]
  end

  defp build_games_query(query, criteria),
    do: Enum.reduce(criteria, query, &compose_games_query/2)

  defp compose_games_query(period, query) when period in [:past_week, :past_day, :past_3_days],
    do: compose_games_query({"period", to_string(period)}, query)

  defp compose_games_query({"period", "past_2_weeks"}, query),
    do: query |> where([game: g], g.inserted_at >= ago(2, "week"))

  defp compose_games_query({"period", "past_week"}, query),
    do: query |> where([game: g], g.inserted_at >= ago(1, "week"))

  defp compose_games_query({"period", "past_day"}, query),
    do: query |> where([game: g], g.inserted_at >= ago(1, "day"))

  defp compose_games_query({"period", "past_3_days"}, query),
    do: query |> where([game: g], g.inserted_at >= ago(3, "day"))

  defp compose_games_query({"period", "past_30_days"}, query),
    do: query |> where([game: g], g.inserted_at >= ago(30, "day"))

  defp compose_games_query({"period", "past_60_days"}, query),
    do: query |> where([game: g], g.inserted_at >= ago(60, "day"))

  defp compose_games_query({"period", "all"}, query),
    do: query

  defp compose_games_query({"period", "throne_of_the_tides"}, query) do
    release = ~N[2022-06-01 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "koft_he"}, query) do
    release = ~N[2022-11-01 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "lich_king"}, query) do
    release = ~N[2022-12-06 18:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_prince_renathal"}, query) do
    release = ~N[2022-06-27 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_2022-09-09"}, query) do
    release = ~N[2022-09-09 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_2022-08-16"}, query) do
    release = ~N[2022-08-16 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_2022-06-16"}, query) do
    release = ~N[2022-06-16 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_2022-05-19"}, query) do
    release = ~N[2022-05-19 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "murder"}, query) do
    release = ~N[2022-08-02 17:00:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "sunken_city"}, query) do
    release = ~N[2022-04-12 17:00:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_2022-04-26"}, query) do
    release = ~N[2022-04-26 20:30:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "alterac_valley"}, query) do
    av_release = ~N[2021-12-07 18:00:00]
    query |> where([game: g], g.inserted_at >= ^av_release)
  end

  defp compose_games_query({"period", "onyxias_lair"}, query) do
    release = ~N[2022-02-15 18:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "bc_2021-12-20"}, query) do
    # they were an hour late
    balance_changes = ~N[2021-12-20 19:00:00]
    query |> where([game: g], g.inserted_at >= ^balance_changes)
  end

  defp compose_games_query({"period", "patch_2022-12-09"}, query) do
    release = ~N[2022-12-09 18:30:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_2022-12-19"}, query) do
    release = ~N[2022-12-19 18:30:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_2023-01-26"}, query) do
    release = ~N[2023-01-26 18:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "disorder"}, query) do
    release = ~N[2022-09-27 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "naxxramas"}, query) do
    release = ~N[2023-02-14 18:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "gnoll_nerf"}, query) do
    release = ~N[2023-03-02 18:50:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_2023-03-14"}, query) do
    release = ~N[2023-03-14 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_2023-04-04"}, query) do
    release = ~N[2023-04-04 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "festival_of_legends"}, query) do
    release = ~N[2023-04-11 17:30:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_26.0.2"}, query) do
    release = ~N[2023-04-15 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_26.0.4"}, query) do
    release = ~N[2023-04-27 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query(rank, query) when rank in [:legend, :diamond_to_legend],
    do: compose_games_query({"rank", to_string(rank)}, query)

  defp compose_games_query({"rank", "legend"}, query),
    do: query |> where([game: g], g.player_rank >= 51)

  defp compose_games_query({"rank", "diamond_to_legend"}, query),
    do: query |> where([game: g], g.player_rank >= 41)

  defp compose_games_query({"rank", "all"}, query),
    do: query

  defp compose_games_query({"order_by", "latest"}, query = %{group_bys: []}),
    do: query |> order_by([game: g], desc: g.inserted_at)

  defp compose_games_query({"order_by", "latest"}, query),
    do: query |> order_by([game: g], desc: max(g.inserted_at))

  defp compose_games_query({"order_by", "total"}, query),
    do: query |> order_by([game: g], desc: @total_select_pos)

  defp compose_games_query({"order_by", "winrate"}, query),
    do: query |> order_by([], desc: @winrate_select_pos)

  defp compose_games_query(order_by, query) when order_by in [:latest, :winrate, :total],
    do: compose_games_query({"order_by", to_string(order_by)}, query)

  defp compose_games_query({"player_deck_includes", cards}, query),
    do: query |> where([player_deck: pd], fragment("? @> ?", pd.cards, ^cards))

  defp compose_games_query({"player_deck_excludes", cards}, query),
    do: query |> where([player_deck: pd], not fragment("? && ?", pd.cards, ^cards))

  defp compose_games_query({"player_deck_id", deck_id}, query),
    do: query |> where([game: g], g.player_deck_id == ^deck_id)

  defp compose_games_query({"player_btag", btag}, query),
    do: query |> where([game: g], g.player_btag == ^btag)

  defp compose_games_query({"player_class", class}, query),
    do: query |> where([game: g], g.player_class == ^String.upcase(class))

  defp compose_games_query({"player_rank", rank}, query),
    do: query |> where([game: g], g.player_rank == ^rank)

  defp compose_games_query({"archetype", "any"}, query), do: query

  defp compose_games_query({"archetype", "other"}, query),
    do: query |> where([player_deck: pd], is_nil(pd.archetype))

  defp compose_games_query({"archetype", archetype}, query),
    do: query |> where([player_deck: pd], pd.archetype == ^archetype)

  defp compose_games_query({"player_deck_archetype", archetypes}, query) when is_list(archetypes),
    do: query |> where([player_deck: pd], pd.archetype in ^archetypes)

  defp compose_games_query({"min_games", min_games_string}, query)
       when is_binary(min_games_string) do
    case Integer.parse(min_games_string) do
      {min, _} -> compose_games_query({"min_games", min}, query)
      _ -> query
    end
  end

  defp compose_games_query({"min_games", min_games}, query),
    do: query |> having([game: g], sum(fragment(@total_fragment, g.status)) >= ^min_games)

  defp compose_games_query({"player_legend_rank", legend_rank}, query),
    do: query |> where([game: g], g.player_legend_rank == ^legend_rank)

  defp compose_games_query({"opponent_class", class}, query),
    do: query |> where([game: g], g.opponent_class == ^String.upcase(class))

  defp compose_games_query({"opponent_rank", rank}, query),
    do: query |> where([game: g], g.opponent_rank == ^rank)

  defp compose_games_query({"opponent_legend_rank", legend_rank}, query),
    do: query |> where([game: g], g.opponent_legend_rank == ^legend_rank)

  defp compose_games_query({"opponent_btag_like", btag}, query),
    do: query |> where([game: g], ilike(g.opponent_btag, ^"%#{btag}%"))

  defp compose_games_query({"turns", turns}, query),
    do: query |> where([game: g], g.turns == ^turns)

  defp compose_games_query({"duration", duration}, query),
    do: query |> where([game: g], g.duration == ^duration)

  defp compose_games_query({"region", region}, query),
    do: query |> where([game: g], g.region == ^region)

  defp compose_games_query(:ranked, query), do: compose_games_query({"game_type", 7}, query)

  defp compose_games_query({"game_type", game_types}, query) when is_list(game_types),
    do: query |> where([game: g], g.game_type in ^game_types)

  defp compose_games_query({"game_type", game_type}, query),
    do: query |> where([game: g], g.game_type == ^game_type)

  defp compose_games_query({"no_archetype", _}, query),
    do: query |> where([player_deck: pd], is_nil(pd.archetype))

  for {id, atom} <- Format.all(:atoms) do
    defp compose_games_query(unquote(atom), query),
      do: compose_games_query({"format", unquote(id)}, query)
  end

  defp compose_games_query({"format", "all"}, query),
    do: query

  defp compose_games_query({"format", format}, query),
    do: query |> where([game: g], g.format == ^format)

  defp compose_games_query({"status", status}, query),
    do: query |> where([game: g], g.status == ^status)

  defp compose_games_query({"has_replay_url", true}, query),
    do: query |> where([game: g], not is_nil(g.replay_url))

  defp compose_games_query({"has_replay_url", _}, query), do: query

  defp compose_games_query("has_result", query) do
    results = ["win", "loss", "draw"]
    query |> where([game: g], g.status in ^results)
  end

  defp compose_games_query(:not_self_report, query),
    do: query |> where([game: g], g.source != "SELF_REPORT")

  defp compose_games_query({"public", public}, query) when public in ["true", "yes"],
    do: compose_games_query({"public", true}, query)

  defp compose_games_query({"public", public}, query) when public in ["false", "no"],
    do: compose_games_query({"public", false}, query)

  defp compose_games_query({"public", public}, query) do
    query |> where([game: g], g.public == ^public)
  end

  defp compose_games_query({"in_group", %GroupMembership{group_id: group_id}}, query) do
    query
    |> join(:inner, [game: g], u in User, on: u.battletag == g.player_btag)
    |> join(:inner, [_g, d, u], gm in GroupMembership, on: gm.user_id == u.id)
    |> where([_g, _d, _u, gm], gm.group_id == ^group_id and gm.include_data == true)
  end

  defp compose_games_query({"limit", limit}, query), do: query |> limit(^limit)
  defp compose_games_query({"offset", offset}, query), do: query |> offset(^offset)

  @spec replay_link(%{:game_id => any, optional(any) => any}) :: String.t() | nil
  def replay_link(%{replay_url: url}) when is_binary(url), do: url

  # def replay_link(%{api_user: nil, game_id: game_id}),
  #   do: "https://hsreplay.net/replay/#{game_id}"
  def replay_link(%{source_id: id, game_id: game_id}) when is_nil(id),
    do: "https://replays.firestoneapp.com/?reviewId=#{game_id}"

  def replay_link(_), do: nil
end
