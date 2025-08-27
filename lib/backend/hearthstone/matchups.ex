defprotocol Backend.Hearthstone.Matchups do
  @type stats :: %{winrate: number(), games: integer()}
  @spec archetype(t) :: atom()
  def archetype(matchups)

  @spec total_stats(t) :: stats()
  def total_stats(matchups)

  @spec opponent_stats(t, atom() | t) :: stats()
  def opponent_stats(matchups, opponent)
end

defimpl Backend.Hearthstone.Matchups, for: Backend.Tournaments.ArchetypeStats do
  alias Backend.Hearthstone.Matchups

  @empty_stats %{winrate: 0, games: 0}
  def archetype(%{archetype: archetype}), do: archetype

  def total_stats(%{wins: wins, losses: losses}), do: wins_losses_to_stats(wins, losses)

  def opponent_stats(%{heads_up: heads_up}, opponent_raw) do
    opponent =
      if Matchups.impl_for(opponent_raw) do
        Matchups.archetype(opponent_raw)
      else
        opponent_raw
      end

    case Map.get(heads_up, opponent) do
      %{wins: wins, losses: losses} -> wins_losses_to_stats(wins, losses)
      _ -> @empty_stats
    end
  end

  defp wins_losses_to_stats(w, l) do
    wins = w || 0
    losses = l || 0

    if wins + losses == 0 do
      @empty_stats
    else
      %{winrate: wins / (wins + losses), games: wins + losses}
    end
  end
end

defimpl Backend.Hearthstone.Matchups, for: Tuple do
  alias Backend.Hearthstone.Matchups
  def archetype({_, matchups}), do: Matchups.archetype(matchups)

  def opponent_stats({_, matchups}, opponent) do
    Matchups.opponent_stats(matchups, opponent)
  end

  def total_stats({_, matchups}), do: Matchups.total_stats(matchups)
end
