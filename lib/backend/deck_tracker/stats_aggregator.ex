defmodule Hearthstone.DeckTracker.StatsAggregator do
  @moduledoc "Aggregates games into stats"
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.DeckTracker.Rank
  alias Hearthstone.DeckTracker.AggregatedStatsCollection
  alias Hearthstone.DeckTracker.AggregatedStatsCollection.Intermediate
  alias Backend.Repo

  @spec aggregate_games([Game.t()], [Rank.t()], String.t() | nil) ::
          {:ok, [Map.t()]} | {:error, String.t()}

  def aggregate_games(games, ranks, archetype)
      when is_list(games) and is_list(ranks) and
             is_binary(archetype) do
    Task.async(fn -> aggregate_group(games, ranks, archetype) end)
    |> Task.await(:infinity)
  end

  def aggregate_games(games, ranks, nil) when is_list(games) and is_list(ranks) do
    games
    |> Enum.group_by(fn %{player_deck: deck} -> Deck.archetype(deck) end)
    |> Util.async_map(fn {archetype, games} ->
      aggregate_group(games, ranks, archetype)
    end)
  end

  @spec auto_aggregate_period(String.t(), integer(), Keyword.t()) :: any()
  def auto_aggregate_period(
        period,
        format,
        opts \\ [chunk_size: 1_000_000]
      ) do
    chunk_size = Keyword.get(opts, :chunk_size, 1_000_000)

    start_time = NaiveDateTime.utc_now()

    ranks = DeckTracker.ranks(auto_aggregate: true)

    base_criteria =
      [
        {"period", period},
        {"format", format},
        {"game_type", 7},
        {"until", NaiveDateTime.utc_now()}
      ] ++ rank_criteria(ranks)

    archetype_chunks = archetype_chunks(base_criteria, chunk_size)
    archetype_chunks_count = Enum.count(archetype_chunks)

    table_name = "dt_#{period}_#{format}_aggregated_stats"
    temp_table_name = "temp_#{table_name}"
    index_name = "#{table_name}_index"
    temp_index_name = "temp_#{index_name}"
    now = NaiveDateTime.utc_now()

    result =
      Repo.transaction(
        fn repo ->
          create_table = """
            CREATE TABLE IF NOT EXISTS #{temp_table_name} (
            deck_id integer,
            rank varchar,
            opponent_class varchar,
            archetype varchar,
            format integer,
            winrate double precision,
            wins integer,
            losses integer,
            total integer,
            turns double precision,
            duration double precision,
            player_has_coin boolean,
            card_stats jsonb
          )
          """

          create_result = repo.query(create_table)
          inserter = chunked_inserter(table_name, repo)

          for {archetypes, index} <- archetype_chunks |> Enum.with_index(1) do
            IO.puts(
              "Starting to process archetype chunk #{index}/#{archetype_chunks_count} with count #{Enum.count(archetypes)} #{NaiveDateTime.diff(NaiveDateTime.utc_now(), start_time)}s in at #{NaiveDateTime.utc_now()}"
            )

            games_criteria = [
              {"with_card_tallies", true},
              {"player_deck_archetype", archetypes} | base_criteria
            ]

            games = DeckTracker.games(games_criteria, timeout: :infinity)

            IO.puts(
              "Fetched #{Enum.count(games)} games for archetype chunk #{index}/#{archetype_chunks_count} with count #{Enum.count(archetypes)} #{NaiveDateTime.diff(NaiveDateTime.utc_now(), start_time)}s in at #{NaiveDateTime.utc_now()}"
            )

            case archetypes do
              [archetype] ->
                aggregate_games(games, ranks, archetype) |> inserter.()

              _ ->
                for group <- aggregate_games(games, ranks, nil) do
                  inserter.(group)
                end
            end

            IO.puts(
              "Finished with insertes for archetype chunk #{index}/#{archetype_chunks_count} with count #{Enum.count(archetypes)} #{NaiveDateTime.diff(NaiveDateTime.utc_now(), start_time)}s in at #{NaiveDateTime.utc_now()}"
            )
          end

          create_index_and_swap = [
            "CREATE INDEX #{temp_index_name} ON #{temp_table_name}(total, COALESCE(deck_id, -1),  COALESCE(archetype, 'any'), COALESCE(opponent_class, 'any'), rank, format, player_has_coin) ;",
            "ALTER INDEX IF EXISTS #{index_name} RENAME TO old_#{index_name} ;",
            "ALTER INDEX IF EXISTS #{temp_index_name} RENAME TO #{index_name} ;",
            "ALTER TABLE IF EXISTS #{table_name} RENAME TO old_#{table_name} ;",
            "ALTER TABLE IF EXISTS #{temp_table_name} RENAME TO #{table_name};",
            "DROP TABLE IF EXISTS old_#{table_name}",
            "COMMENT ON table #{table_name} IS '#{now}';"
          ]

          after_result =
            for sql <- create_index_and_swap do
              repo.query(sql)
            end

          [create_result, after_result]
        end,
        timeout: :infinity
      )

    IO.puts("Finished all in #{NaiveDateTime.diff(NaiveDateTime.utc_now(), start_time)} seconds ")
    result
  end

  defp chunked_inserter(table_name, repo) do
    fn intermediate ->
      for chunk <- Enum.chunk_every(intermediate, 5000) do
        insertable =
          Enum.map(chunk, fn {key, value} ->
            Intermediate.to_insertable(value, key)
          end)

        repo.insert_all(table_name, insertable)
      end
    end
  end

  defp archetype_chunks(criteria, chunk_size) do
    archetype_popularity = DeckTracker.archetype_popularity(criteria)

    Enum.chunk_while(
      archetype_popularity,
      {[], 0},
      fn %{archetype: archetype, count: count}, {archetypes, total} ->
        new_total = total + count
        new_archetypes = [archetype | archetypes]

        if new_total > chunk_size do
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

    Map.merge(intermediate, archetype_map)
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
