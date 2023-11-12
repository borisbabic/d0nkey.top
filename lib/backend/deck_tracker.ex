defmodule Hearthstone.DeckTracker do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi

  alias Backend.Repo
  alias Backend.Hearthstone.DeckBag
  alias Hearthstone.DeckTracker.AggregatedStats
  alias Hearthstone.DeckTracker.AggregationLog
  alias Hearthstone.DeckTracker.CardGameTally
  # alias Hearthstone.DeckTracker.DeckStats
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.DeckTracker.Period
  alias Hearthstone.DeckTracker.RawPlayerCardStats
  alias Hearthstone.DeckTracker.Source
  alias Hearthstone.Enums.Format, as: FormatEnum
  alias Hearthstone.DeckTracker.Rank
  alias Hearthstone.DeckTracker.Format
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Backend.UserManager
  alias Backend.UserManager.User
  alias Backend.UserManager.GroupMembership

  use Torch.Pagination,
    repo: Backend.Repo,
    model: Hearthstone.DeckTracker.Period,
    name: :periods

  @type deck_stats :: %{deck: Deck.t(), wins: integer(), losses: integer()}

  @spec get_game(integer) :: Game.t() | nil
  def get_game(id), do: Repo.get(Game, id) |> Repo.preload(:player_deck)

  @spec get_game_by_game_id(String.t()) :: Game.t() | nil
  def get_game_by_game_id(game_id) do
    query =
      from(g in Game,
        preload: [:player_deck, :source],
        where: g.game_id == ^game_id
      )

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
      from(g in Game,
        as: :game,
        preload: [:player_deck],
        where: g.inserted_at > ago(90, "second")
      )

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

  @period_hardcodes [:past_week, :past_day, :past_3_days]
  @rank_hardcodes [:all, :legend, :diamond_to_legend, :top_legend]
  def unhardcode_criteria(criteria) do
    criteria
    |> Enum.map(fn a ->
      cond do
        a in @period_hardcodes -> {"period", to_string("a")}
        a in @rank_hardcodes -> {"rank", to_string("a")}
        true -> a
      end
    end)
  end

  def get_latest_agg_log_entry() do
    query = from al in AggregationLog, order_by: [desc: :inserted_at], limit: 1
    Repo.one(query)
  end

  @nil_agg_deck_id -1
  @nil_agg_archetype "any"
  @nil_agg_opponent_class "any"
  def convert_deck_criteria_to_aggregate(raw_deck_criteria) do
    criteria =
      raw_deck_criteria
      |> unhardcode_criteria()
      |> remove_game_type()

    %{ranks: ranks, periods: periods, formats: formats} = get_latest_agg_log_entry()

    deck_id = Util.keyfind_value(criteria, "player_deck_id", 0)
    period = Util.keyfind_value(criteria, "period", 0)
    rank = Util.keyfind_value(criteria, "rank", 0)
    format = Util.keyfind_value(criteria, "format", 0)

    opponent_class? = List.keymember?(criteria, "opponent_class", 0)
    player_btag? = List.keymember?(criteria, "player_btag", 0)

    cond do
      player_btag? ->
        {:error, :per_player_aggregation_not_supported}

      !period ->
        {:error, :no_period_for_agg}

      !rank ->
        {:error, :no_rank_for_agg}

      !opponent_class? ->
        {:error, :no_opponent_class_for_agg}

      format && Util.to_int_or_orig(format) not in formats ->
        {:error, "format #{format} not aggregated"}

      rank not in ranks ->
        {:error, "rank #{rank} not aggregaed"}

      period not in periods ->
        {:error, "period #{period} not aggregaed"}

      format && (!deck_id or deck_id < 1) ->
        {:ok, List.keystore(criteria, "player_deck_id", 0, {"player_deck_id", :not_null})}

      !format ->
        %{format: format} = Hearthstone.get_deck(deck_id)
        {:ok, List.keystore(criteria, "format", 0, {"format", format})}

      true ->
        {:ok, criteria}
    end
  end

  defp remove_game_type(criteria) do
    case List.keyfind(criteria, "game_type", 0) do
      [7] -> List.keydelete(criteria, "game_type", 0)
      7 -> List.keydelete(criteria, "game_type", 0)
      _ -> criteria
    end
    |> Enum.reject(&(&1 == :ranked))
  end

  @spec deck_stats(integer(), list()) :: [deck_stats()]
  def deck_stats(deck_id, additional_criteria) do
    deck_stats([{"player_deck_id", deck_id} | additional_criteria])
  end

  @spec deck_stats(integer() | list() | Map.t()) :: [deck_stats()]
  def deck_stats(deck_id) when is_integer(deck_id) do
    deck_stats(deck_id, [])
  end

  def deck_stats(criteria) do
    {base_query, new_criteria} = base_deck_stats_query(criteria)

    build_games_query(base_query, new_criteria)
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

  @type card_stats :: %{
          card_id: integer(),
          drawn_count: integer(),
          drawn_impact: float(),
          mull_count: integer(),
          mull_impact: float(),
          kept_count: integer(),
          kept_impact: float()
        }

  @spec merge_card_deck_stats(list()) :: [card_stats]
  def merge_card_deck_stats(criteria) do
    {_, query_timeout} =
      criteria
      |> Enum.to_list()
      |> List.keyfind("timeout", 0, {"timeout", 15_000})

    await_timeout = 1000 + Util.to_int!(query_timeout, 15_000)

    [
      deck_card_stats,
      deck_stats
    ] =
      [
        Task.async(fn -> deck_card_stats(criteria) end),
        Task.async(fn -> deck_stats(criteria) end)
      ]
      |> Task.await_many(await_timeout)

    merge_card_deck_stats(deck_card_stats, deck_stats)
  end

  @spec merge_card_deck_stats(list(), list()) :: [card_stats]
  def merge_card_deck_stats(deck_card_stats, deck_stats) do
    deck_winrate_map =
      for %{deck_id: id, winrate: winrate} <- deck_stats, into: %{}, do: {id, winrate}

    deck_card_stats
    |> Enum.reduce(%{}, fn ct, acc ->
      deck_winrate = deck_winrate_map[ct.deck_id] || 0

      drawn_total = ct.drawn_wins + ct.drawn_losses
      drawn_winrate = safe_div(ct.drawn_wins, drawn_total)
      drawn_diff = drawn_winrate - deck_winrate

      mull_total = ct.mulligan_wins + ct.mulligan_losses
      mull_winrate = safe_div(ct.mulligan_wins, mull_total)
      mull_diff = mull_winrate - deck_winrate

      kept_total = ct.kept_wins + ct.kept_losses
      kept_winrate = safe_div(ct.kept_wins, kept_total)
      kept_diff = kept_winrate - deck_winrate

      Map.put_new(acc, ct.card_id, %{
        cum_drawn_diff: 0,
        drawn_total: 0,
        cum_mull_diff: 0,
        mull_total: 0,
        cum_kept_diff: 0,
        kept_total: 0
      })
      |> update_in([ct.card_id, :cum_drawn_diff], &(&1 + drawn_diff * drawn_total))
      |> update_in([ct.card_id, :drawn_total], &(&1 + drawn_total))
      |> update_in([ct.card_id, :cum_mull_diff], &(&1 + mull_diff * mull_total))
      |> update_in([ct.card_id, :mull_total], &(&1 + mull_total))
      |> update_in([ct.card_id, :cum_kept_diff], &(&1 + kept_diff * kept_total))
      |> update_in([ct.card_id, :kept_total], &(&1 + kept_total))
    end)
    |> Enum.map(fn {card_id, cum} ->
      %{
        card_id: card_id,
        drawn_count: cum.drawn_total,
        drawn_impact: safe_div(cum.cum_drawn_diff, cum.drawn_total),
        mull_count: cum.mull_total,
        mull_impact: safe_div(cum.cum_mull_diff, cum.mull_total),
        kept_count: cum.kept_total,
        kept_impact: safe_div(cum.cum_kept_diff, cum.kept_total)
      }
    end)
  end

  defp safe_div(0, _divisor), do: 0 / 1
  defp safe_div(_dividend, 0), do: 0 / 1
  defp safe_div(dividend, divisor), do: dividend / divisor

  def deck_card_stats(criteria) do
    base_deck_card_stats_query()
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

  def agg_deck_card_stats(criteria) do
    base_agg_deck_card_stats_query()
    |> build_games_query(criteria)
    |> Repo.all()
  end

  defp base_agg_deck_card_stats_query() do
    from(ag in AggregatedStats,
      as: :agg_deck_stats,
      left_join: pd in assoc(ag, :deck),
      as: :player_deck,
      select: %{
        wins: ag.wins,
        losses: ag.losses,
        total: ag.total,
        winrate: ag.winrate,
        deck_id: ag.deck_id,
        card_stats: ag.card_stats
      }
    )
  end

  defp base_agg_deck_stats_query() do
    from(ag in AggregatedStats,
      as: :agg_deck_stats,
      join: pd in assoc(ag, :deck),
      as: :player_deck,
      select: %{
        wins: ag.wins,
        losses: ag.losses,
        total: ag.total,
        winrate: ag.winrate,
        deck_id: ag.deck_id
      }
    )
  end

  defp base_deck_stats_query(criteria) do
    list_criteria = Enum.to_list(criteria)

    with :nomatch <- List.keyfind(list_criteria, "force_fresh", 0, :nomatch),
         {:ok, new_criteria} <- convert_deck_criteria_to_aggregate(list_criteria) do
      {base_agg_deck_stats_query(), new_criteria}
    else
      _ ->
        {base_deck_stats_query(), List.keydelete(list_criteria, "force_fresh", 0)}
    end
  end

  defp ensure_opponent_class(criteria) do
    case List.keyfind(criteria, "opponent_class", 0) do
      {"opponent_class", c} when is_binary(c) -> criteria
      _ -> [{"opponent_class", "ALL"} | criteria]
    end
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
    from(g in Game,
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
    )
  end

  defp base_deck_card_stats_query() do
    from(ct in CardGameTally,
      as: :card_tally,
      join: g in assoc(ct, :game),
      as: :game,
      join: pd in assoc(ct, :deck),
      as: :player_deck,
      group_by: [ct.card_id, ct.deck_id],
      select: %{
        kept_wins:
          sum(
            fragment(
              "CASE WHEN ? = 'win' AND ? AND ? THEN 1 ELSE 0 END",
              g.status,
              ct.kept,
              ct.mulligan
            )
          ),
        kept_losses:
          sum(
            fragment(
              "CASE WHEN ? = 'loss' AND ? AND ? THEN 1 ELSE 0 END",
              g.status,
              ct.kept,
              ct.mulligan
            )
          ),
        drawn_wins:
          sum(fragment("CASE WHEN ? = 'win' AND ? THEN 1 ELSE 0 END", g.status, ct.drawn)),
        drawn_losses:
          sum(fragment("CASE WHEN ? = 'loss' AND ? THEN 1 ELSE 0 END", g.status, ct.drawn)),
        mulligan_wins:
          sum(fragment("CASE WHEN ? = 'win' AND ? THEN 1 ELSE 0 END", g.status, ct.mulligan)),
        mulligan_losses:
          sum(fragment("CASE WHEN ? = 'loss' AND ? THEN 1 ELSE 0 END", g.status, ct.mulligan)),
        card_id: ct.card_id,
        deck_id: ct.deck_id
      }
    )
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
      from(s in Source,
        where: s.source == ^source and s.version == ^version
      )

    Repo.one(query)
  end

  def get_source(_, _), do: nil

  defp handle_deck(code) when is_binary(code),
    do: Hearthstone.create_or_get_deck(code) |> DeckBag.check_archetype()

  defp handle_deck(nil), do: {:ok, nil}

  defp get_existing(game_id) do
    query =
      from(g in Game,
        as: :game,
        preload: [:player_deck],
        where: g.game_id == ^game_id
      )

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
    from(g in Game,
      as: :game,
      left_join: pd in assoc(g, :player_deck),
      as: :player_deck,
      left_join: source in assoc(g, :source),
      as: :source,
      preload: [player_deck: pd, source: source]
    )
  end

  defp build_games_query(query, criteria) do
    criteria
    |> unhardcode_criteria()
    |> Enum.reduce(query, &compose_games_query/2)
  end

  @old_aggregated_query %{from: %{as: :deck_stats}}
  @agg_deck_query %{from: %{as: :agg_deck_stats}}
  @card_query %{from: %{as: :card_tally}}

  defp compose_games_query({"period", period}, query = @agg_deck_query) do
    query
    |> where([agg_deck_stats: ag], ag.period == ^to_string(period))
  end

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

  defp compose_games_query({"period", "patch_26.2.2"}, query) do
    release = ~N[2023-05-19 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "audiopocalypse"}, query) do
    release = ~N[2023-05-31 17:15:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_26.4.3"}, query) do
    release = ~N[2023-06-15 17:20:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_26.6.0"}, query) do
    release = ~N[2023-06-27 17:20:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  defp compose_games_query({"period", "patch_26.6.2"}, query) do
    release = ~N[2023-07-06 18:20:00]
    query |> where([game: g], g.inserted_at >= ^release)
  end

  for {param, ago_num, ago_period} <- [
        {"past_2_weeks", 2, "week"},
        {"past_week", 1, "week"},
        {"past_day", 1, "day"},
        {"past_3_days", 3, "day"},
        {"past_30_days", 30, "day"},
        {"past_60_days", 60, "day"}
      ] do
    defp compose_games_query({"period", unquote(param)}, query = @card_query) do
      query
      |> where([card_tally: ct], ct.inserted_at >= ago(unquote(ago_num), unquote(ago_period)))
    end

    defp compose_games_query({"period", unquote(param)}, query = @old_aggregated_query) do
      query
      |> where([deck_stats: ds], ds.hour_start >= ago(unquote(ago_num), unquote(ago_period)))
    end

    defp compose_games_query({"period", unquote(param)}, query) do
      query |> where([game: g], g.inserted_at >= ago(unquote(ago_num), unquote(ago_period)))
    end
  end

  for {param, start} <- [
        {"patch_27.4.3", "2023-10-03 17:40:00"},
        {"patch_27.4.2", "2023-09-28 17:20:00"},
        {"patch_27.2.2", "2023-08-30 16:20:00"},
        {"miniset_titans", "2023-09-19 17:10:00"},
        {"titans", "2023-08-01 17:20:00"},
        {"patch_27.2", "2023-08-22 17:20:00"}
      ] do
    defp compose_games_query({"period", unquote(param)}, query = @old_aggregated_query) do
      {:ok, start_time} = NaiveDateTime.from_iso8601(unquote(start))
      query |> where([deck_stats: ds], ds.hour_start >= ^start_time)
    end

    defp compose_games_query({"period", unquote(param)}, query) do
      {:ok, start_time} = NaiveDateTime.from_iso8601(unquote(start))
      query |> where([game: g], g.inserted_at >= ^start_time)
    end

    defp compose_games_query({"period", unquote(param)}, query = @card_query) do
      {:ok, start_time} = NaiveDateTime.from_iso8601(unquote(start))
      query |> where([card_tally: c], c.inserted_at >= ^start_time)
    end
  end

  defp compose_games_query({"period", slug}, query = @old_aggregated_query) do
    subquery = period_start_query(slug)
    period_start = %{} = Repo.one(subquery)

    query
    |> where([deck_stats: ds], ds.hour_start >= ^period_start)
  end

  defp compose_games_query({"period", slug}, query = @card_query) do
    subquery = period_start_query(slug)
    period_start = %{} = Repo.one(subquery)

    query
    |> where([card_tally: ct], ct.inserted_at >= ^period_start)
  end

  defp compose_games_query({"period", slug}, query) do
    subquery = period_start_query(slug)
    period_start = %{} = Repo.one(subquery)

    query
    |> where([game: g], g.inserted_at >= ^period_start)
  end

  def period_start_query(slug) do
    from p in Period,
      where: p.slug == ^slug,
      select:
        max(
          fragment(
            "COALESCE (?, now() - CONCAT(?, ' hours')::interval)",
            p.period_start,
            p.hours_ago
          )
        )
  end

  defp compose_games_query({:in_range, start, finish}, query) do
    query
    |> where([game: g], g.inserted_at >= ^start and g.inserted_at < ^finish)
  end

  defp compose_games_query({"rank", r}, query = @agg_deck_query),
    do: query |> where([agg_deck_stats: ag], ag.rank == ^r)

  defp compose_games_query({"rank", r}, query = @old_aggregated_query),
    do: query |> where([deck_stats: ds], ds.rank == ^r)

  defp compose_games_query({"rank", "legend"}, query),
    do: query |> where([game: g], g.player_rank >= 51)

  defp compose_games_query({"rank", "top_legend"}, query),
    do: query |> where([game: g], g.player_rank >= 51 and g.player_legend_rank <= 1000)

  defp compose_games_query({"rank", "diamond_to_legend"}, query),
    do: query |> where([game: g], g.player_rank >= 41)

  defp compose_games_query({"rank", "all"}, query),
    do: query

  defp compose_games_query({"rank", slug}, query) do
    rank = get_rank_by_slug(slug)

    query
    |> filter_rank(rank, :game, :player_rank, :player_legend_rank)
  end

  defp filter_rank(
         query,
         %{
           min_rank: min_rank,
           max_rank: max_rank,
           min_legend_rank: min_legend_rank,
           max_legend_rank: max_legend_rank
         },
         target,
         rank_field,
         legend_field
       ) do
    [
      {
        min_rank > 0,
        &where(&1, [{^target, t}], field(t, ^rank_field) >= ^min_rank)
      },
      {
        is_integer(max_rank) and max_rank > 0,
        &where(&1, [{^target, t}], field(t, ^rank_field) <= ^max_rank)
      },
      {
        min_legend_rank > 0,
        &where(&1, [{^target, t}], field(t, ^legend_field) >= ^min_legend_rank)
      },
      {
        is_integer(max_legend_rank) and max_legend_rank > 0,
        &where(&1, [{^target, t}], field(t, ^legend_field) <= ^max_legend_rank)
      }
    ]
    |> Enum.reduce(query, fn
      {true, apply}, acc_query -> apply.(acc_query)
      {false, _apply}, acc_query -> acc_query
    end)
  end

  defp compose_games_query({"order_by", "latest"}, query = %{group_bys: []}),
    do: query |> order_by([game: g], desc: g.inserted_at)

  defp compose_games_query({"order_by", "latest"}, query),
    do: query |> order_by([game: g], desc: max(g.inserted_at))

  defp compose_games_query({"order_by", "total"}, query),
    do: query |> order_by([], desc: @total_select_pos)

  defp compose_games_query({"order_by", "winrate"}, query),
    do: query |> order_by([], desc: @winrate_select_pos)

  defp compose_games_query(order_by, query) when order_by in [:latest, :winrate, :total],
    do: compose_games_query({"order_by", to_string(order_by)}, query)

  defp compose_games_query({"player_deck_includes", cards}, query),
    do: query |> where([player_deck: pd], fragment("? @> ?", pd.cards, ^cards))

  defp compose_games_query({"player_deck_excludes", cards}, query),
    do: query |> where([player_deck: pd], not fragment("? && ?", pd.cards, ^cards))

  defp compose_games_query({"player_deck_id", :not_null}, query = @agg_deck_query) do
    query
    |> where(
      [agg_deck_stats: ag],
      fragment("COALESCE (?, ?)", ag.deck_id, ^@nil_agg_deck_id) != ^@nil_agg_deck_id
    )
  end

  defp compose_games_query({"player_deck_id", deck_id}, query = @agg_deck_query) do
    actual_deck_id = deck_id || @nil_agg_deck_id

    query
    |> where(
      [agg_deck_stats: ag],
      fragment("COALESCE (?, ?)", ag.deck_id, ^@nil_agg_deck_id) == ^actual_deck_id
    )
  end

  defp compose_games_query({"player_deck_id", deck_id}, query = @card_query),
    do: query |> where([card_tally: ct], ct.deck_id == ^deck_id)

  defp compose_games_query({"player_deck_id", deck_id}, query),
    do: query |> where([game: g], g.player_deck_id == ^deck_id)

  defp compose_games_query({"player_btag", btag}, query),
    do: query |> where([game: g], g.player_btag == ^btag)

  defp compose_games_query({"player_class", class}, query = @agg_deck_query),
    do: query |> where([player_deck: d], d.class == ^String.upcase(class))

  defp compose_games_query({"player_class", class}, query),
    do: query |> where([game: g], g.player_class == ^String.upcase(class))

  defp compose_games_query({"player_rank", rank}, query),
    do: query |> where([game: g], g.player_rank == ^rank)

  defp compose_games_query({"archetype", archetype}, query = @agg_deck_query) do
    arch = archetype || @nil_agg_archetype

    query
    |> where(
      [agg_deck_stats: ag],
      fragment("COALESCE(?, ?)", ag.archetype, @nil_agg_archetype) == ^arch
    )
  end

  defp compose_games_query({"archetype", "any"}, query), do: query

  defp compose_games_query({"archetype", "other"}, query),
    do: query |> where([player_deck: pd], is_nil(pd.archetype))

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

  defp compose_games_query({"min_games", min_games}, query = @agg_deck_query),
    do: query |> where([agg_deck_stats: ag], ag.total >= ^min_games)

  defp compose_games_query({"min_games", min_games}, query = @old_aggregated_query),
    do: query |> having([deck_stats: ds], sum(ds.total) >= ^min_games)

  defp compose_games_query({"min_games", min_games}, query),
    do: query |> having([game: g], sum(fragment(@total_fragment, g.status)) >= ^min_games)

  defp compose_games_query({"player_legend_rank", legend_rank}, query),
    do: query |> where([game: g], g.player_legend_rank == ^legend_rank)

  defp compose_games_query({"opponent_class", class}, query = @agg_deck_query) do
    query
    |> where(
      [agg_deck_stats: ag],
      fragment("COALESCE (?, ?)", ag.opponent_class, ^@nil_agg_opponent_class) ==
        fragment("COALESCE (?, ?)", ^class, ^@nil_agg_opponent_class)
    )
  end

  defp compose_games_query({"opponent_class", class}, query = @old_aggregated_query),
    do: query |> where([deck_stats: ds], ds.opponent_class == ^String.upcase(class))

  defp compose_games_query({"opponent_class", "any"}, query), do: query

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

  defp compose_games_query(:ranked, @agg_deck_query = query), do: query
  defp compose_games_query(:ranked, @old_aggregated_query = query), do: query
  defp compose_games_query(:ranked, query), do: compose_games_query({"game_type", 7}, query)

  defp compose_games_query({"game_type", [7]}, @agg_deck_query = query),
    do: query

  defp compose_games_query({"game_type", [7]}, @old_aggregated_query = query),
    do: query

  defp compose_games_query({"game_type", game_types}, query) when is_list(game_types),
    do: query |> where([game: g], g.game_type in ^game_types)

  defp compose_games_query({"game_type", game_type}, query),
    do: query |> where([game: g], g.game_type == ^game_type)

  defp compose_games_query({"no_archetype", _}, query),
    do: query |> where([player_deck: pd], is_nil(pd.archetype))

  for {id, atom} <- FormatEnum.all(:atoms) do
    defp compose_games_query(unquote(atom), query),
      do: compose_games_query({"format", unquote(id)}, query)
  end

  defp compose_games_query({"format", all}, query) when all in [nil, "", "all"],
    do: query

  defp compose_games_query({"format", format}, query = @agg_deck_query),
    do: query |> where([agg_deck_stats: ag], ag.format == ^format)

  defp compose_games_query({"format", format}, query = @old_aggregated_query),
    do: query |> where([player_deck: pd], pd.format == ^format)

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

  defp compose_games_query({"use_aggregated", _}, query), do: query

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

  defp compose_games_query({"limit", limit}, query) when is_integer(limit) or is_binary(limit),
    do: query |> limit(^limit)

  defp compose_games_query({"offset", offset}, query), do: query |> offset(^offset)

  @spec replay_link(%{:game_id => any, optional(any) => any}) :: String.t() | nil
  def replay_link(%{replay_url: url}) when is_binary(url), do: url

  # def replay_link(%{api_user: nil, game_id: game_id}),
  #   do: "https://hsreplay.net/replay/#{game_id}"
  def replay_link(%{source: %{source: "firestone"}, game_id: game_id}),
    do: firestone_replay(game_id)

  def replay_link(%{source_id: id, game_id: game_id}) when is_nil(id),
    do: firestone_replay(game_id)

  def replay_link(_), do: nil

  def firestone_replay(game_id), do: "https://replays.firestoneapp.com/?reviewId=#{game_id}"

  @spec raw_stats_for_game(Game.t()) :: RawPlayerCardStats.t() | nil
  def raw_stats_for_game(%{id: id}) do
    query =
      from(r in RawPlayerCardStats,
        where: r.game_id == ^id,
        limit: 1
      )

    Repo.one(query)
  end

  @spec card_tallies_for_game(Game.t()) :: [CardGameTall.t()]
  def card_tallies_for_game(%{id: id}) do
    query =
      from(r in CardGameTally,
        where: r.game_id == ^id
      )

    Repo.all(query)
  end

  @default_convert_raw_stats_to_card_tallies_opts [
    limit: 100,
    per_query_timeout: 120_000,
    min_id: 0,
    times: :infinite
  ]
  def convert_raw_stats_to_card_tallies(
        opts_raw \\ @default_convert_raw_stats_to_card_tallies_opts
      ) do
    opts = Keyword.merge(@default_convert_raw_stats_to_card_tallies_opts, opts_raw)

    limit = Keyword.get(opts, :limit)
    timeout = Keyword.get(opts, :per_query_timeout)
    times = Keyword.get(opts, :times)
    min_id = Keyword.get(opts, :min_id)

    raw_stats(limit, min_id)
    |> do_convert_raw_stats_to_card_tallies(limit, timeout, times)
  end

  defp do_convert_raw_stats_to_card_tallies(_, limit, timeout, times, min_in \\ 0)

  defp do_convert_raw_stats_to_card_tallies(_, _limit, _timeout, times, _min_id)
       when is_integer(times) and times < 1,
       do: :ok

  defp do_convert_raw_stats_to_card_tallies([], _limit, _timeout, _times, _max_id), do: :ok

  defp do_convert_raw_stats_to_card_tallies(fetched, limit, timeout, times, min_id) do
    {multi, new_min_id} =
      fetched
      |> Enum.reduce({Multi.new(), min_id}, fn raw_stats, {multi, max_id} ->
        %{drawn: drawn, mull: mull} = RawPlayerCardStats.dtos(raw_stats)
        attrs_result = GameDto.create_card_tally_ecto_attrs(mull, drawn, raw_stats.game_id)

        new_multi =
          case attrs_result do
            {:ok, attrs} ->
              multi
              |> Multi.insert_all(
                "insert_tallies_from_#{raw_stats.id}_for_#{raw_stats.game_id}",
                CardGameTally,
                attrs
              )
              |> Multi.delete("delete_raw_stats_#{raw_stats.id}", raw_stats)

            {:error, _} ->
              multi
          end

        {new_multi, Enum.max([max_id, raw_stats.id])}
      end)

    Repo.transaction(multi, timeout: timeout)

    new_times = if is_integer(times), do: times - 1, else: times

    raw_stats(limit, new_min_id)
    |> do_convert_raw_stats_to_card_tallies(limit, timeout, times, new_min_id)
  end

  def raw_stats(limit, min_id \\ 0) do
    query =
      from(r in RawPlayerCardStats,
        where: r.id > ^min_id,
        order_by: [asc: r.id],
        limit: ^limit
      )

    Repo.all(query)
  end

  @doc """
  Returns the list of periods.

  ## Examples

      iex> list_periods()
      [%Period{}, ...]

  """
  def list_periods do
    Repo.all(Period)
  end

  @doc """
  Gets a single period.

  Raises `Ecto.NoResultsError` if the Period does not exist.

  ## Examples

      iex> get_period!(123)
      %Period{}

      iex> get_period!(456)
      ** (Ecto.NoResultsError)

  """
  def get_period!(id), do: Repo.get!(Period, id)

  @doc """
  Creates a period.

  ## Examples

      iex> create_period(%{field: value})
      {:ok, %Period{}}

      iex> create_period(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_period(attrs \\ %{}) do
    %Period{}
    |> Period.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a period.

  ## Examples

      iex> update_period(period, %{field: new_value})
      {:ok, %Period{}}

      iex> update_period(period, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_period(%Period{} = period, attrs) do
    period
    |> Period.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Period.

  ## Examples

      iex> delete_period(period)
      {:ok, %Period{}}

      iex> delete_period(period)
      {:error, %Ecto.Changeset{}}

  """
  def delete_period(%Period{} = period) do
    Repo.delete(period)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking period changes.

  ## Examples

      iex> change_period(period)
      %Ecto.Changeset{source: %Period{}}

  """
  def change_period(%Period{} = period, attrs \\ %{}) do
    Period.changeset(period, attrs)
  end

  @one_hour %Timex.Duration{microseconds: 0, seconds: 3_600, megaseconds: 0}

  # def aggregate_deck_stats(class, rank)
  #     when (is_binary(class) or is_nil(class)) and is_binary(rank) do
  #   NaiveDateTime.utc_now()
  #   |> Timex.subtract(@one_hour)
  #   |> Util.hour_start()
  #   |> aggregate_deck_stats(class, rank)
  # end
  #
  # def aggregate_deck_stats(%NaiveDateTime{} = start, class, rank)
  #     when (is_binary(class) or is_nil(class)) and is_binary(rank) do
  #   finish = Timex.add(start, @one_hour)
  #
  #   if :gt == NaiveDateTime.compare(finish, NaiveDateTime.utc_now()) do
  #     raise "Can't aggregate an unfinished period"
  #   end
  #
  #   base_criteria = [
  #     {:in_range, start, finish},
  #     {"rank", rank}
  #   ]
  #
  #   criteria =
  #     base_criteria
  #     |> add_opponent_class_criteria(class)
  #
  #   query =
  #     base_deck_stats_query()
  #     |> build_games_query(criteria)
  #
  #   constants = %{hour_start: start, opponent_class: class, rank: rank}
  #
  #   Repo.all(query, timeout: 666_000)
  #   |> Enum.reduce(Multi.new(), fn ds, multi ->
  #     attrs = Map.merge(ds, constants)
  #
  #     cs = DeckStats.changeset(%DeckStats{}, attrs)
  #     name = to_string(attrs.deck_id)
  #     Multi.insert(multi, name, cs)
  #   end)
  #   |> Repo.transaction(timeout: 666_000)
  # end
  #
  # def aggregate_deck_stats(%Date{} = date, hour, class) when is_integer(hour) do
  #   with {:ok, time} <- Time.new(hour, 0, 0),
  #        {:ok, start} <- NaiveDateTime.new(date, time) do
  #     aggregate_deck_stats(start, class)
  #   end
  # end

  defp add_opponent_class_criteria(criteria, all) when all in [nil, "ALL", "all"], do: criteria
  defp add_opponent_class_criteria(criteria, class), do: [{"opponent_class", class} | criteria]

  @spec format_filters(:public | :personal) :: [{value :: String.t(), display :: String.t()}]
  def format_filters(context) do
    formats_for_filters(context)
    |> Enum.map(&Format.to_option/1)
  end

  @spec formats_for_filters(:public | :personal) :: [Format.t()]
  def formats_for_filters(context) do
    [{:context, context}, {:order_by, {:order_priority, :desc}}]
    |> formats()
  end

  def get_format_by_value(value) do
    query = from(p in Format, where: p.value == ^value)

    Repo.one(query)
  end

  def formats(criteria) do
    base_formats_query()
    |> build_formats_query(criteria)
    |> Repo.all()
  end

  defp base_formats_query() do
    from(p in Format, as: :format)
  end

  defp build_formats_query(query, criteria) do
    Enum.reduce(criteria, query, &compose_formats_query/2)
  end

  defp compose_formats_query({:context, :public}, query) do
    query |> where([format: p], p.include_in_deck_filters == true)
  end

  defp compose_formats_query({:context, :personal}, query) do
    query |> where([format: p], p.include_in_personal_filters == true)
  end

  defp compose_formats_query({:default, default}, query) do
    query |> where([format: p], p.default == ^default)
  end

  defp compose_formats_query({:order_by, {field, direction}}, query) do
    query
    |> order_by(
      [format: p],
      [{^direction, field(p, ^field)}]
    )
  end

  @spec default_format(:public | :personal) :: String.t()
  def default_format(context) do
    [{:default, true}, {:order_by, {:order_priority, :desc}}, {:context, context}]
    |> formats()
    |> case do
      [%{value: value} | _] -> value
      _ -> "diamond_to_legend"
    end
  end

  ######
  @spec rank_filters(:public | :personal) :: [{slug :: String.t(), display :: String.t()}]
  def rank_filters(context) do
    ranks_for_filters(context)
    |> Enum.map(&Rank.to_option/1)
  end

  @spec ranks_for_filters(:public | :personal) :: [Rank.t()]
  def ranks_for_filters(context) do
    [{:context, context}, {:order_by, {:order_priority, :desc}}]
    |> ranks()
  end

  def get_rank_by_slug(slug) do
    query = from(p in Rank, where: p.slug == ^slug)

    Repo.one(query)
  end

  def ranks(criteria) do
    base_ranks_query()
    |> build_ranks_query(criteria)
    |> Repo.all()
  end

  defp base_ranks_query() do
    from(p in Rank, as: :rank)
  end

  defp build_ranks_query(query, criteria) do
    Enum.reduce(criteria, query, &compose_ranks_query/2)
  end

  defp compose_ranks_query({:context, :public}, query) do
    query |> where([rank: p], p.include_in_deck_filters == true)
  end

  defp compose_ranks_query({:context, :personal}, query) do
    query |> where([rank: p], p.include_in_personal_filters == true)
  end

  defp compose_ranks_query({:default, default}, query) do
    query |> where([rank: p], p.default == ^default)
  end

  defp compose_ranks_query({:order_by, {field, direction}}, query) do
    query
    |> order_by(
      [rank: p],
      [{^direction, field(p, ^field)}]
    )
  end

  @spec default_rank(:public | :personal) :: String.t()
  def default_rank(context) do
    [{:default, true}, {:order_by, {:order_priority, :desc}}, {:context, context}]
    |> ranks()
    |> case do
      [%{slug: slug} | _] -> slug
      _ -> "diamond_to_legend"
    end
  end

  ########################
  @spec period_filters(:public | :personal) :: [{slug :: String.t(), display :: String.t()}]
  def period_filters(context) do
    periods_for_filters(context)
    |> Enum.map(&Period.to_option/1)
  end

  @spec periods_for_filters(:public | :personal) :: [Period.t()]
  def periods_for_filters(context) do
    [{:context, context}, {:order_by, {:order_priority, :desc}}]
    |> periods()
  end

  def get_period_by_slug(slug) do
    query = from(p in Period, where: p.slug == ^slug)

    Repo.one(query)
  end

  def periods(criteria) do
    base_periods_query()
    |> build_periods_query(criteria)
    |> Repo.all()
  end

  defp base_periods_query() do
    from(p in Period, as: :period)
  end

  defp build_periods_query(query, criteria) do
    Enum.reduce(criteria, query, &compose_periods_query/2)
  end

  defp compose_periods_query({:context, :public}, query) do
    query |> where([period: p], p.include_in_deck_filters == true)
  end

  defp compose_periods_query({:context, :personal}, query) do
    query |> where([period: p], p.include_in_personal_filters == true)
  end

  defp compose_periods_query({:order_by, {field, direction}}, query) do
    query
    |> order_by(
      [period: p],
      [{^direction, field(p, ^field)}]
    )
  end

  defp compose_periods_query({:in_range, field, start, finish}, query) do
    query |> where([period: p], field(p, ^field) >= ^start and field(p, ^field) < ^finish)
  end

  defp compose_periods_query({:type, type}, query) do
    query |> where([period: p], p.type == ^type)
  end

  @spec default_period() :: String.t()
  def default_period() do
    now = NaiveDateTime.utc_now()
    start = now |> Timex.shift(days: -10)
    finish_patch = now |> Timex.shift(hours: -5)
    finish_release = now

    criteria = [
      {:order_by, {:period_start, :desc}}
    ]

    periods(criteria)
    |> Enum.find_value("past_week", fn
      %{type: "patch", period_start: ps, slug: slug} ->
        NaiveDateTime.compare(ps, start) == :gt and NaiveDateTime.compare(ps, finish_patch) == :lt &&
          slug

      %{type: "release", period_start: ps, slug: slug} ->
        NaiveDateTime.compare(ps, start) == :gt and
          NaiveDateTime.compare(ps, finish_release) == :lt && slug

      _ ->
        false
    end)
  end

  use Torch.Pagination,
    repo: Backend.Repo,
    model: Hearthstone.DeckTracker.Rank,
    name: :ranks

  @doc """
  Returns the list of ranks.

  ## Examples

      iex> list_ranks()
      [%Rank{}, ...]

  """
  def list_ranks do
    Repo.all(Rank)
  end

  @doc """
  Gets a single rank.

  Raises `Ecto.NoResultsError` if the Rank does not exist.

  ## Examples

      iex> get_rank!(123)
      %Rank{}

      iex> get_rank!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rank!(id), do: Repo.get!(Rank, id)

  @doc """
  Creates a rank.

  ## Examples

      iex> create_rank(%{field: value})
      {:ok, %Rank{}}

      iex> create_rank(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rank(attrs \\ %{}) do
    %Rank{}
    |> Rank.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rank.

  ## Examples

      iex> update_rank(rank, %{field: new_value})
      {:ok, %Rank{}}

      iex> update_rank(rank, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rank(%Rank{} = rank, attrs) do
    rank
    |> Rank.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Rank.

  ## Examples

      iex> delete_rank(rank)
      {:ok, %Rank{}}

      iex> delete_rank(rank)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rank(%Rank{} = rank) do
    Repo.delete(rank)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rank changes.

  ## Examples

      iex> change_rank(rank)
      %Ecto.Changeset{source: %Rank{}}

  """
  def change_rank(%Rank{} = rank, attrs \\ %{}) do
    Rank.changeset(rank, attrs)
  end

  use Torch.Pagination,
    repo: Backend.Repo,
    model: Hearthstone.DeckTracker.Format,
    name: :formats

  @doc """
  Returns the list of formats.

  ## Examples

      iex> list_formats()
      [%Format{}, ...]

  """
  def list_formats do
    Repo.all(Format)
  end

  @doc """
  Gets a single format.

  Raises `Ecto.NoResultsError` if the Format does not exist.

  ## Examples

      iex> get_format!(123)
      %Format{}

      iex> get_format!(456)
      ** (Ecto.NoResultsError)

  """
  def get_format!(id), do: Repo.get!(Format, id)

  @doc """
  Creates a format.

  ## Examples

      iex> create_format(%{field: value})
      {:ok, %Format{}}

      iex> create_format(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_format(attrs \\ %{}) do
    %Format{}
    |> Format.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a format.

  ## Examples

      iex> update_format(format, %{field: new_value})
      {:ok, %Format{}}

      iex> update_format(format, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_format(%Format{} = format, attrs) do
    format
    |> Format.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Format.

  ## Examples

      iex> delete_format(format)
      {:ok, %Format{}}

      iex> delete_format(format)
      {:error, %Ecto.Changeset{}}

  """
  def delete_format(%Format{} = format) do
    Repo.delete(format)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking format changes.

  ## Examples

      iex> change_format(format)
      %Ecto.Changeset{source: %Format{}}

  """
  def change_format(%Format{} = format, attrs \\ %{}) do
    Format.changeset(format, attrs)
  end

  def refresh_agg_stats() do
    Repo.query!(
      "
    DO $$
    DECLARE cnt int;
    declare r record;
    begin
      SELECT count(1) INTO cnt FROM pg_stat_activity WHERE query LIKE '%REFRESH MATERIALIZED VIEW CONCURRENTLY dt_aggregated_stats%' and pid != pg_backend_pid();
      IF cnt < 1 then
        REFRESH MATERIALIZED VIEW CONCURRENTLY dt_aggregated_stats WITH DATA ;
      END IF;
    END $$;
    ",
      [],
      timeout: :infinity
    )
  end
end
