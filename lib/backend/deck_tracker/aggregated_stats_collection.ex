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
        card_stats: card_stats
      }
    }
  end

  def new(_), do: {:error, :unsupported_status}

  def wins_losses(%{status: status}), do: wins_losses(status)
  def wins_losses(:win), do: {1, 0}
  def wins_losses(:loss), do: {0, 0}

  def merge(first, second) do
    %__MODULE__{
      wins: first.wins + second.wins,
      losses: first.losses + second.losses,
      total_turns: first.total_turns + second.total_turns,
      turns_total_games: first.turns_total_games + second.turns_total_games,
      total_duration: first.total_duration + second.total_duration,
      duration_total_games: first.duration_total_games + second.duration_total_games,
      card_stats_wins: first.card_stats_wins + second.card_stats_wins,
      card_stats_losses: first.card_stats_losses + second.card_stats_losses,
      card_stats: IntermediateCardStats.merge_maps(first.card_stats, second.card_stats)
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

  def add_to_map(map, %{card_game_tallies: [_ | _] = tallies, player_deck: deck, status: status}) do
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
      if tally.mull do
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
