defmodule Hearthstone.DeckTracker.StatsAggregator do
  @moduledoc "Aggregates games into stats"
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.DeckTracker.Rank
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
        opts \\ [chunk_size: 1_000_000, sort_dir: :desc]
      ) do
    chunk_size = Keyword.get(opts, :chunk_size, 1_000_000)
    sort_dir = Keyword.get(opts, :sort_dir, :desc)

    start_time = NaiveDateTime.utc_now()

    ranks = DeckTracker.ranks(auto_aggregate: true)

    base_criteria =
      [
        {"period", period},
        {"format", format},
        {"game_type", 7},
        {"until", NaiveDateTime.utc_now()}
      ] ++ rank_criteria(ranks)

    archetype_chunks = archetype_chunks(base_criteria, chunk_size, sort_dir)
    archetype_chunks_count = Enum.count(archetype_chunks) |> to_string()
    pad = String.length(archetype_chunks_count)

    table_name = DeckTracker.aggregated_stats_table_name(period, format)
    temp_table_name = "temp_#{table_name}"
    index_name = "#{table_name}_index"
    temp_index_name = "temp_#{index_name}"
    # ensure_temp_table_ready(temp_table_name, temp_index_name)
    now = NaiveDateTime.utc_now()

    result =
      Repo.transaction(
        fn repo ->
          create_table = """
            CREATE TABLE IF NOT EXISTS "#{temp_table_name}" (
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
            climbing_speed double precision,
            player_has_coin boolean,
            card_stats jsonb
          )
          """

          create_result = repo.query(create_table)
          inserter = chunked_inserter(temp_table_name, repo)

          for {archetypes, index} <- archetype_chunks |> Enum.with_index(1) do
            chunk_start_time = NaiveDateTime.utc_now()

            output_message = fn message, part ->
              prefix =
                "#{String.pad_leading(to_string(index), pad, "0")}/#{archetype_chunks_count}"

              now = NaiveDateTime.utc_now()

              now_time =
                case Timex.format(now, "{h24}:{m}:{s}") do
                  {:ok, formatted} -> formatted
                  _ -> now |> NaiveDateTime.to_time() |> to_string()
                end

              padded_diff =
                NaiveDateTime.diff(now, start_time) |> to_string() |> String.pad_leading(4, "0")

              padded_chunk_diff =
                NaiveDateTime.diff(now, chunk_start_time)
                |> to_string()
                |> String.pad_leading(3, "0")

              padded_count =
                archetypes |> Enum.count() |> to_string() |> String.pad_leading(3, "0")

              IO.puts(
                "#{prefix} - #{part} | #{padded_chunk_diff}s | #{padded_diff}s | #{now_time} | #{period}_#{format} | #{padded_count}: #{message}"
              )
            end

            output_message.("Starting to process archetype chunk", 1)

            games_criteria = [
              {"with_card_tallies", true},
              {"player_deck_archetype", archetypes} | base_criteria
            ]

            games = DeckTracker.games(games_criteria, timeout: :infinity)

            output_message.("Fetched #{Enum.count(games)} games", 2)

            case archetypes do
              [archetype] ->
                aggregate_games(games, ranks, archetype) |> inserter.()

              _ ->
                for group <- aggregate_games(games, ranks, nil) do
                  inserter.(group)
                end
            end

            output_message.("Finished inserting", 3)
          end

          create_index_and_swap = [
            "CREATE INDEX \"#{temp_index_name}\" ON \"#{temp_table_name}\"(total, COALESCE(deck_id, -1),  COALESCE(archetype, 'any'), COALESCE(opponent_class, 'any'), rank, format, player_has_coin) ;",
            "ALTER INDEX IF EXISTS \"#{index_name}\" RENAME TO \"old_#{index_name}\" ;",
            "ALTER INDEX IF EXISTS \"#{temp_index_name}\" RENAME TO \"#{index_name}\" ;",
            "ALTER TABLE IF EXISTS \"#{table_name}\" RENAME TO \"old_#{table_name}\" ;",
            "ALTER TABLE IF EXISTS \"#{temp_table_name}\" RENAME TO \"#{table_name}\";",
            "DROP TABLE IF EXISTS \"old_#{table_name}\"",
            "COMMENT ON table \"#{table_name}\" IS '#{now}';"
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

  # TODO: If optimization is needed we can do this then paralelize the inserts and swap tables in a transaction
  # ie
  # ensure_temp_table_ready()
  # for chunk <- chunks, do: fetch(chunk) |> async_process_and_insert()
  # Repo.transactino(fn -> create index, swap temp and actual table end)
  #
  #
  # # ensure we don't get passed something we don't want to truncate
  # def ensure_temp_table_ready("temp_" <> _ = temp_table_name, temp_index_name) do
  #   create_table = """
  #     CREATE TABLE IF NOT EXISTS #{temp_table_name} (
  #     deck_id integer,
  #     rank varchar,
  #     opponent_class varchar,
  #     archetype varchar,
  #     format integer,
  #     winrate double precision,
  #     wins integer,
  #     losses integer,
  #     total integer,
  #     turns double precision,
  #     duration double precision,
  #     player_has_coin boolean,
  #     card_stats jsonb
  #   )
  #   """

  #   truncate_table = """
  #     TRUNCATE TABLE #{temp_table_name};
  #   """

  #   drop_index = """
  #     DROP INDEX IF EXISTS #{temp_index_name};
  #   """

  #   Repo.transaction(fn repo ->
  #     repo.query(create_table)
  #     repo.query(truncate_table)
  #     repo.query(drop_index)
  #   end)
  # end

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

  defp archetype_chunks(criteria, chunk_size, direction) do
    archetype_popularity = DeckTracker.archetype_popularity(criteria, direction)

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
                 Intermediate.merge(first, second, :collect)

               {_, first}, second ->
                 Intermediate.merge(first, second, :collect)
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
