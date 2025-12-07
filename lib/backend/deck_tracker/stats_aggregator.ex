defmodule Hearthstone.DeckTracker.StatsAggregator do
  @moduledoc "Aggregates games into stats"
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.DeckTracker.Rank
  alias Hearthstone.DeckTracker.AggregatedStatsCollection
  alias Hearthstone.DeckTracker.AggregatedStatsCollection.Intermediate

  @spec aggregate_games([Game.t()], [Rank.t()]) ::
          {:ok, AggregatedStatsCollection} | {:error, String.t()}
  def aggregate_games(games, ranks) when is_list(games) and is_list(ranks) do
    games
    |> Enum.group_by(fn %{player_deck: deck} -> Deck.archetype(deck) end)
    |> Util.async_map(fn {archetype, games} ->
      aggregate_group(games, ranks, archetype)
    end)
    |> Enum.reduce(%{}, &Map.merge/2)
  end

  def aggregate_for_period(period, format) do
    ranks = DeckTracker.ranks(auto_aggregate: true)

    base_criteria =
      [
        {"period", period},
        {"format", format},
        {"game_type", 7},
        {"until", NaiveDateTime.utc_now()}
      ] ++ rank_criteria(ranks)

    archetype_popularity = DeckTracker.archetype_popularity()

    chunks =
      Enum.chunk_while(
        archetype_popularity,
        {[], 0},
        fn %{archetype: archetype, count: count}, {archetypes, total} ->
          new_total = total + count
          new_archetypes = [archetype | archetypes]

          if new_total > 1_000_000 do
            {:cont, new_archetypes, {[], 0}}
          else
            {:cont, {new_archetypes, new_total}}
          end
        end,
        fn
          {[_ | _] = archetypes, _} -> {:cont, archetypes, {[], 0}}
          _ -> {:cont, {[], 0}}
        end
      )

    IO.puts("Number of chunks: #{Enum.count(chunks)}")

    Enum.reduce(chunks, %{}, fn archetypes, acc ->
      games_criteria = [
        {"with_card_tallies", true},
        {"player_deck_archetype", archetypes} | base_criteria
      ]

      games = DeckTracker.games(games_criteria, timeout: :infinity)

      aggregate_games(games, ranks)
      |> Map.merge(acc)

      # before = NaiveDateTime.utc_now()
      # games = DeckTracker.games(games_criteria, timeout: :infinity)
      # after_fetch = NaiveDateTime.utc_now()
      # IO.puts("Fetching #{archetype} took #{NaiveDateTime.diff(after_fetch, before)}")
      # aggregated = aggregate_group(games, ranks, archetype)
      # after_aggregated = NaiveDateTime.utc_now()
      # IO.puts("Aggregating #{archetype} took #{NaiveDateTime.diff(after_aggregated, after_fetch)}")
      # group = Enum.map(aggregated, fn {key, value} -> Intermediate.to_insertable(value, key) end)
      # after_to_insertable = NaiveDateTime.utc_now()
      # IO.puts("Converting #{archetype} took #{NaiveDateTime.diff(after_to_insertable, after_aggregated)}")

      # result = group ++ acc
      # IO.puts("Concating took #{NaiveDateTime.diff(NaiveDateTime.utc_now(), after_to_insertable)}")
      # result
    end)
    |> Enum.map(fn {key, value} ->
      Intermediate.to_insertable(value, key)
    end)
  end

  defp rank_criteria(ranks) do
    if Enum.any?(ranks, &(&1.slug == "all")) do
      []
    else
      %{min_rank: min_rank} = Enum.min_by(ranks, & &1.min_rank)
      [{"min_player_rank", min_rank}]
    end
  end

  defp aggregate_group(games, ranks, archetype) do
    intermediate =
      Enum.reduce(games, Map.new(), fn
        %{player_deck_id: deck_id} = game, coll when is_integer(deck_id) ->
          keys = keys(game, ranks)

          case Intermediate.new(game) do
            {:ok, intermediate} ->
              Enum.reduce(keys, coll, fn key, acc ->
                Map.update(acc, key, intermediate, &Intermediate.merge(&1, intermediate))
              end)

            _ ->
              coll
          end

        _, coll ->
          coll
      end)

    archetype_map =
      intermediate
      |> Enum.group_by(fn {key, _value} ->
        List.keydelete(key, "deck_id", 0)
      end)
      |> Map.new(fn {partial_key, values} ->
        key = [{"archetype", archetype} | partial_key]

        {key,
         case values do
           [{_key, value}] ->
             value

           [] ->
             []

           _ ->
             Enum.reduce(values, fn
               {_, first}, {_, second} ->
                 Intermediate.merge(first, second)

               {_, first}, second ->
                 Intermediate.merge(first, second)
             end)
         end}
      end)

    Map.merge(archetype_map, intermediate)
  end

  def keys(game, ranks) do
    base =
      [{"deck_id", game.player_deck_id}]

    matching_ranks =
      Enum.filter(ranks, &Rank.game_matches?(&1, game)) |> Enum.map(&{"rank", &1.slug})

    variant_options =
      [
        {"opponent_class", game.opponent_class},
        {"player_has_coin", game.player_has_coin}
        # {"opponent_pc_archetype", Game.opponent_pc_archetype(game)}
      ]
      |> Enum.map(fn {key, value} ->
        [nil | Util.to_list(value)]
        |> Enum.uniq()
        |> Enum.map(&{key, &1})
      end)

    combinations = [matching_ranks | variant_options] |> Util.combinations()

    for b <- base, combination <- combinations do
      [b | combination]
    end
  end

  # defp filter_not_nil(list) do
  #   Enum.filter(list, fn {_key, val} -> val != nil end)
  # end
end
