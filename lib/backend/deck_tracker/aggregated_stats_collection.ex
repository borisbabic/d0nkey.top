defmodule Hearthstone.DeckTracker.AggregatedStatsCollection do
end

defmodule Hearthstone.DeckTracker.AggregatedStatsCollection.Intermediate do
  use TypedStruct

  alias Hearthstone.DeckTracker.AggregatedStatsCollection.IntermediateCardStats

  typedstruct do
    field :wins, :integer
    field :losses, :integer
    field :total_turns, :integer
    field :turns_total_games, :integer
    field :total_duration, :integer
    field :duration_total_games, :integer
    field :card_stats_wins, :integer
    field :card_stats_losses, :integer
    field :card_stats, Map.t()
    field :card_stats_collection, list() | nil
  end

  @spec new(Hearthstone.DeckTracker.Game.t()) :: {:ok, t()} | {:error, reason :: atom()}
  def new(%{status: status} = game) when status in [:win, :loss] do
    {wins, losses} = wins_losses(status)

    {total_turns, turns_total_games} =
      if is_integer(game.turns) do
        {game.turns, 1}
      else
        {0, 0}
      end

    {total_duration, duration_total_games} =
      if is_integer(game.duration) do
        {game.duration, 1}
      else
        {0, 0}
      end

    {card_stats_wins, card_stats_losses, card_stats} =
      case IntermediateCardStats.add_to_map(%{}, game) do
        {:ok, card_stats} ->
          {wins, losses, card_stats}

        _ ->
          {0, 0, %{}}
      end

    {
      :ok,
      %__MODULE__{
        wins: wins,
        losses: losses,
        total_turns: total_turns,
        turns_total_games: turns_total_games,
        total_duration: total_duration,
        duration_total_games: duration_total_games,
        card_stats_wins: card_stats_wins,
        card_stats_losses: card_stats_losses,
        card_stats: card_stats,
        card_stats_collection: nil
      }
    }
  end

  def new(_), do: {:error, :unsupported_status}

  def wins_losses(%{status: status}), do: wins_losses(status)
  def wins_losses(:win), do: {1, 0}
  def wins_losses(:loss), do: {0, 1}

  def merge(first, second, card_stats_merge_type \\ :merge) do
    cs_wins = first.card_stats_wins + second.card_stats_wins
    cs_losses = first.card_stats_losses + second.card_stats_losses
    card_stats = IntermediateCardStats.merge_maps(first.card_stats, second.card_stats)

    card_stats_collection =
      case card_stats_merge_type do
        :merge ->
          nil

        :collect ->
          card_stats_collection(first) ++ card_stats_collection(second)
      end

    %__MODULE__{
      wins: first.wins + second.wins,
      losses: first.losses + second.losses,
      total_turns: first.total_turns + second.total_turns,
      turns_total_games: first.turns_total_games + second.turns_total_games,
      total_duration: first.total_duration + second.total_duration,
      duration_total_games: first.duration_total_games + second.duration_total_games,
      card_stats_wins: cs_wins,
      card_stats_losses: cs_losses,
      card_stats: card_stats,
      card_stats_collection: card_stats_collection
    }
  end

  def card_stats_collection(%__MODULE__{card_stats_collection: csc}) when is_list(csc) do
    csc
  end

  def card_stats_collection(%__MODULE__{
        card_stats_wins: csw,
        card_stats_losses: csl,
        card_stats: cs
      }) do
    [{csw, csl, cs}]
  end

  def to_insertable(int, %{"archetype" => arch} = other_fields)
      when is_atom(arch) and not is_nil(arch) do
    new_other_fields = Map.put(other_fields, "archetype", to_string(arch))
    to_insertable(int, new_other_fields)
  end

  def to_insertable(int, other_fields) when is_map(other_fields) do
    duration =
      if int.duration_total_games > 0 do
        int.total_duration / int.duration_total_games
      else
        0
      end

    total = int.wins + int.losses

    winrate =
      if total > 0 do
        int.wins / total
      else
        0
      end

    climbing_speed =
      if duration > 0 do
        3600 / duration * (2 * winrate - 1)
      else
        0
      end

    %{
      "total" => total,
      "wins" => int.wins,
      "losses" => int.losses,
      "winrate" => winrate,
      "turns" =>
        if(int.turns_total_games == 0, do: 0, else: int.total_turns / int.turns_total_games),
      "duration" => duration,
      "climbing_speed" => climbing_speed,
      "card_stats" => insertable_card_stats(int) || [],
      # ensure below are present
      "deck_id" => nil,
      "archetype" => nil,
      "opponent_class" => nil
    }
    |> Map.merge(other_fields)
  end

  def to_insertable(int, other_fields), do: to_insertable(int, Map.new(other_fields))

  def insertable_card_stats(int) do
    csc = card_stats_collection(int)

    reduced =
      Enum.reduce(csc, %{}, fn
        {wins, losses, _card_stats}, acc when wins + losses == 0 ->
          acc

        {wins, losses, card_stats}, outer_acc ->
          winrate = wins / (wins + losses)

          Enum.reduce(card_stats, outer_acc, fn {_, card_stats}, acc ->
            curr = partial_insertable_card_stats(card_stats, winrate)

            Map.update(acc, card_stats.card_id, curr, fn prev ->
              Map.merge(prev, curr, fn _, a, b -> a + b end)
            end)
          end)
      end)

    Enum.map(reduced, &factors_to_impacts/1)
  end

  defp factors_to_impacts({card_id, factors}) do
    drawn_impact =
      if factors["drawn_total"] > 0 do
        factors["drawn_impact_factor"] / factors["drawn_total"]
      else
        0
      end

    mull_impact =
      if factors["mull_total"] > 0 do
        factors["mull_impact_factor"] / factors["mull_total"]
      else
        0
      end

    kept_impact =
      if factors["kept_total"] > 0 do
        factors["kept_impact_factor"] / factors["kept_total"]
      else
        0
      end

    tossed_impact =
      if factors["tossed_total"] > 0 do
        factors["tossed_impact_factor"] / factors["tossed_total"]
      else
        0
      end

    not_drawn_impact =
      if factors["not_drawn_total"] > 0 do
        factors["not_drawn_impact_factor"] / factors["not_drawn_total"]
      else
        0
      end

    %{
      "card_id" => card_id,
      "drawn_total" => factors["drawn_total"],
      "drawn_impact" => drawn_impact,
      "mull_total" => factors["mull_total"],
      "mull_impact" => mull_impact,
      "kept_total" => factors["kept_total"],
      "kept_impact" => kept_impact,
      "tossed_total" => factors["tossed_total"],
      "tossed_impact" => tossed_impact,
      "not_drawn_total" => factors["not_drawn_total"],
      "not_drawn_impact" => not_drawn_impact
    }
  end

  defp partial_insertable_card_stats(card_stats, winrate) do
    drawn_total = card_stats.drawn_wins + card_stats.drawn_losses

    drawn_impact_factor =
      if drawn_total > 0 do
        drawn_total * (card_stats.drawn_wins / drawn_total - winrate)
      else
        0
      end

    not_drawn_total = card_stats.not_drawn_wins + card_stats.not_drawn_losses

    not_drawn_impact_factor =
      if not_drawn_total > 0 do
        not_drawn_total * (card_stats.not_drawn_wins / not_drawn_total - winrate)
      else
        0
      end

    mull_total = card_stats.mull_wins + card_stats.mull_losses

    mull_impact_factor =
      if mull_total > 0 do
        mull_total * (card_stats.mull_wins / mull_total - winrate)
      else
        0
      end

    kept_total = card_stats.kept_wins + card_stats.kept_losses

    kept_impact_factor =
      if kept_total > 0 do
        kept_total * (card_stats.kept_wins / kept_total - winrate)
      else
        0
      end

    tossed_total = card_stats.tossed_wins + card_stats.tossed_losses

    tossed_impact_factor =
      if tossed_total > 0 do
        tossed_total * (card_stats.tossed_wins / tossed_total - winrate)
      else
        0
      end

    curr = %{
      "drawn_total" => drawn_total,
      "drawn_impact_factor" => drawn_impact_factor,
      "not_drawn_total" => not_drawn_total,
      "not_drawn_impact_factor" => not_drawn_impact_factor,
      "mull_total" => mull_total,
      "mull_impact_factor" => mull_impact_factor,
      "kept_total" => kept_total,
      "kept_impact_factor" => kept_impact_factor,
      "tossed_total" => tossed_total,
      "tossed_impact_factor" => tossed_impact_factor
    }
  end
end

defmodule Hearthstone.DeckTracker.AggregatedStatsCollection.IntermediateCardStats do
  use TypedStruct

  import Hearthstone.DeckTracker.AggregatedStatsCollection.Intermediate, only: [wins_losses: 1]

  typedstruct do
    field :card_id, :integer
    field :drawn_wins, :integer
    field :drawn_losses, :integer
    field :kept_wins, :integer
    field :kept_losses, :integer
    field :mull_wins, :integer
    field :mull_losses, :integer
    field :tossed_wins, :integer
    field :tossed_losses, :integer
    field :not_drawn_wins, :integer
    field :not_drawn_losses, :integer
  end

  @spec merge(t(), t()) :: t()
  def merge(%{card_id: first_id}, %{card_id: second_id}) when first_id != second_id do
    raise "Card IDs mismatch"
  end

  def merge(%{card_id: card_id} = first_stats, %{card_id: card_id} = second_stats) do
    %__MODULE__{
      card_id: first_stats.card_id,
      drawn_wins: first_stats.drawn_wins + second_stats.drawn_wins,
      drawn_losses: first_stats.drawn_losses + second_stats.drawn_losses,
      kept_wins: first_stats.kept_wins + second_stats.kept_wins,
      kept_losses: first_stats.kept_losses + second_stats.kept_losses,
      mull_wins: first_stats.mull_wins + second_stats.mull_wins,
      mull_losses: first_stats.mull_losses + second_stats.mull_losses,
      tossed_wins: first_stats.tossed_wins + second_stats.tossed_wins,
      tossed_losses: first_stats.tossed_losses + second_stats.tossed_losses,
      not_drawn_wins: first_stats.not_drawn_wins + second_stats.not_drawn_wins,
      not_drawn_losses: first_stats.not_drawn_losses + second_stats.not_drawn_losses
    }
  end

  def merge_maps(first_map, second_map) do
    Map.merge(first_map, second_map, fn _key, first_stats, second_stats ->
      merge(first_stats, second_stats)
    end)
  end

  def add_to_map(map, %{card_tallies: [_ | _] = tallies, player_deck: deck, status: status}) do
    cards_set = MapSet.new(deck.cards)

    wins_losses = wins_losses(status)

    {new_map, undrawn_cards} =
      Enum.reduce(tallies, {map, cards_set}, fn tally, {card_stats_map, undrawn_cards} ->
        stats = tally_to_stats(tally, wins_losses)
        new_map = Map.update(card_stats_map, stats.card_id, stats, &merge(&1, stats))

        new_undrawn_cards =
          if tally.drawn do
            MapSet.delete(undrawn_cards, stats.card_id)
          else
            undrawn_cards
          end

        {new_map, new_undrawn_cards}
      end)

    with_undrawn =
      Enum.reduce(undrawn_cards, new_map, fn card_id, acc ->
        stats = new_undrawn(card_id, wins_losses)
        Map.update(acc, stats.card_id, stats, &merge(&1, stats))
      end)

    {:ok, with_undrawn}
  end

  def add_to_map(_, _), do: :error

  def tally_to_stats(tally, wins_losses) do
    {drawn_wins, drawn_losses} =
      if tally.drawn do
        wins_losses
      else
        {0, 0}
      end

    {kept_wins, kept_losses} =
      if tally.kept do
        wins_losses
      else
        {0, 0}
      end

    {mull_wins, mull_losses} =
      if tally.mulligan do
        wins_losses
      else
        {0, 0}
      end

    %__MODULE__{
      card_id: tally.card_id,
      drawn_wins: drawn_wins,
      drawn_losses: drawn_losses,
      kept_wins: kept_wins,
      kept_losses: kept_losses,
      mull_wins: mull_wins,
      mull_losses: mull_losses,
      tossed_wins: 0,
      tossed_losses: 0,
      not_drawn_wins: 0,
      not_drawn_losses: 0
    }
  end

  defp new_undrawn(card_id, {wins, losses}) do
    %__MODULE__{
      card_id: card_id,
      drawn_wins: 0,
      drawn_losses: 0,
      kept_wins: 0,
      kept_losses: 0,
      mull_wins: 0,
      mull_losses: 0,
      tossed_wins: 0,
      tossed_losses: 0,
      not_drawn_wins: wins,
      not_drawn_losses: losses
    }
  end
end
