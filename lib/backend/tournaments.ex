defmodule Backend.Tournaments do
  @moduledoc false
  alias Backend.Battlefy
  alias Backend.Battlefy.Tournament, as: BattlefyTournament
  alias BobsLeague.Api.Tournament, as: BobsLeagueTournament
  alias Backend.Tournaments.Tournament
  alias Backend.Tournaments.MatchStats
  alias Backend.Tournaments.ArchetypeStats

  @type tournament_tuple :: {tournament_source :: String.t(), tournament_id :: String.t()}
  @type archetype_stats_bag :: %{String.t() => ArchetypeStats.t()}
  @type archetype_stats :: %{
          archetype_stats: archetype_stats_bag(),
          adjusted_winrate_type: atom()
        }
  @supported_sources ["battlefy", "bobsleague"]

  @spec get_tournament(tournament_tuple) :: Tournament.t() | nil
  def get_tournament({"battlefy", id}), do: Battlefy.get_tournament(id)
  def get_tournament(_), do: nil

  @spec get_our_link(tournament_tuple | Tournament.t()) :: String.t() | nil
  def get_our_link(%BattlefyTournament{id: id}), do: get_our_link({"battlefy", id})
  def get_our_link({"battlefy", id}), do: "/battlefy/tournament/#{id}"
  def get_our_link(_), do: nil

  @spec get_source_link(tournament_tuple | Tournament) :: String.t() | nil
  def get_source_link(%BattlefyTournament{} = tournament),
    do: Battlefy.create_tournament_link(tournament)

  def get_source_link({"battlefy", id}), do: Battlefy.create_tournament_link(id)
  def get_source_link(%BobsLeagueTournament{} = t), do: BobsLeagueTournament.link(t)
  def get_source_link({"bobsleague", id}), do: BobsLeagueTournament.link(id)
  def get_source_link(_), do: nil

  @spec get_our_link(tournament_tuple | Tournament.t()) :: String.t() | nil
  def get_any_link(tournament_or_tuple) do
    get_our_link(tournament_or_tuple) || get_source_link(tournament_or_tuple)
  end

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

  @spec archetype_stats({source :: String.t(), id :: String.t()}) ::
          {:ok, archetype_stats()} | {:error, :atom | String.t()}
  def archetype_stats({source, id}), do: archetype_stats(source, id)

  @spec archetype_stats(source :: String.t(), id :: String.t()) ::
          {:ok, archetype_stats()} | {:error, :atom | String.t()}
  def archetype_stats("battlefy", id) do
    with {:ok, t} <- Backend.Battlefy.fetch_tournament(id),
         {:ok, as} <- Backend.Battlefy.archetype_stats(t) do
      awt = Tournament.tags(t) |> Enum.find(&ArchetypeStats.supports_adjusted_winrate?/1)
      {:ok, %{archetype_stats: as, adjusted_winrate_type: awt}}
    end
  end

  def archetype_stats(_, _), do: {:error, :source_not_supported}

  @spec match_stats_and_awt({source :: String.t(), id :: String.t()}) ::
          {[MatchStats.t()], atom()}
  def match_stats_and_awt({source, id}), do: match_stats_and_awt(source, id)

  @spec match_stats_and_awt(source :: String.t(), id :: String.t()) :: {[MatchStats.t()], atom()}
  def match_stats_and_awt("battlefy", id) do
    with {:ok, t} <- Backend.Battlefy.fetch_tournament(id),
         {:ok, ms} <- Backend.Battlefy.match_stats(t) do
      awt = Tournament.tags(t) |> Enum.find(&ArchetypeStats.supports_adjusted_winrate?/1)
      {ms, awt}
    else
      _ -> {[], nil}
    end
  end

  def match_stats_and_awt(_, _), do: {[], nil}

  @spec multi_tournament_archetype_stats([tournament_tuple()]) ::
          {:ok, archetype_stats()} | {:error, :atom | String.t()}
  def multi_tournament_archetype_stats(tournament_tuples) do
    {match_stats, awt} =
      Enum.map(tournament_tuples, &match_stats_and_awt/1)
      |> Enum.reduce(fn {new_ms, new_awt}, {carry_ms, carry_awt} ->
        awt = if new_awt == carry_awt, do: new_awt
        ms = new_ms ++ carry_ms
        {ms, awt}
      end)

    as = calculate_archetype_stats(match_stats)
    {:ok, %{archetype_stats: as, adjusted_winrate_type: awt}}
  end

  def parse_source(source) when source in @supported_sources, do: source
  def parse_source(_), do: nil

  def parse_id(id, source \\ nil)
  def parse_id(id, "battlefy"), do: Backend.Battlefy.tournament_link_to_id(id)
  def parse_id(id, _), do: id
end
