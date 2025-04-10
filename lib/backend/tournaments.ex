defmodule Backend.Tournaments do
  @moduledoc false
  alias Backend.Battlefy
  alias Backend.Battlefy.Tournament, as: BattlefyTournament
  alias Backend.Tournaments.Tournament
  alias Backend.Tournaments.MatchStats
  alias Backend.Tournaments.ArchetypeStats

  @type tournament_tuple :: {tournament_source :: String.t(), tournament_id :: String.t()}
  @type archetype_stats_bag :: %{String.t() => ArchetypeStats.t()}

  @spec get_tournament(tournament_tuple) :: Tournament.t()
  def get_tournament({"battlefy", id}), do: Battlefy.get_tournament(id)
  @spec get_our_link(tournament_tuple | Tournament.t()) :: String.t()
  def get_our_link(%BattlefyTournament{id: id}), do: get_our_link({"battlefy", id})
  def get_our_link({"battlefy", id}), do: "/battlefy/tournament/#{id}"

  @spec get_source_link(tournament_tuple | Tournament) :: String.t()
  def get_source_link(%BattlefyTournament{} = tournament),
    do: Battlefy.create_tournament_link(tournament)

  def get_source_link({"battlefy", id}), do: Battlefy.create_tournament_link(id)

  def filter_newest(tournaments, hours_ago_cutoff) when is_integer(hours_ago_cutoff) do
    cutoff = NaiveDateTime.utc_now() |> Timex.shift(hours: -1 * hours_ago_cutoff)

    Enum.filter(tournaments, fn t ->
      start_time = Tournament.start_time(t)
      start_time && :gt == NaiveDateTime.compare(start_time, cutoff)
    end)
  end

  def filter_newest(tournaments, _), do: tournaments

  @spec calculate_archetype_stats([MatchStats.t()]) :: archetype_stats_bag()
  def calculate_archetype_stats(match_stats) do
    Enum.reduce(match_stats, %{}, fn match_stats, acc ->
      MatchStats.winner_loser_pairs(match_stats)
      # |> IO.inspect(label: :pairs)
      |> Enum.reduce(acc, fn {winner, loser}, archetype_stats ->
        archetype_stats
        |> ArchetypeStats.add_result_to_bag(winner, loser, :wins)
        |> ArchetypeStats.add_result_to_bag(loser, winner, :losses)
      end)
      |> ArchetypeStats.increment_in_bag(match_stats.banned, [:banned])
      |> ArchetypeStats.increment_in_bag(match_stats.not_banned, [:not_banned])
    end)
  end
end
