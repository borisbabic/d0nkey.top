defmodule Hearthstone.DeckTracker.StatsAggregator do
  @moduledoc "Aggregates games into stats"
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.DeckTracker.Rank
  alias Hearthstone.DeckTracker.AggregatedStatsCollection
  alias Hearthstone.DeckTracker.AggregatedStatsCollection.Intermediate

  @spec aggregate_games([Game.t()], [Rank.t()]) ::
          {:ok, AggregatedStatsCollection} | {:error, String.t()}
  def aggregate_games(games, ranks) do
    games
    |> Enum.group_by(fn %{player_deck: deck} -> Deck.archetype(deck) end)
    |> Util.async_map(fn {archetype, games} ->
      aggregate_group(games, ranks, archetype)
    end)
    |> Enum.reduce(%{}, &Map.merge/2)
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

    # |> filter_not_nil()

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
