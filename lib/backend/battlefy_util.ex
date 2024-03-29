defmodule Backend.BattlefyUtil do
  @moduledoc """
  Holds utility functions for battlefy stuff.
  """
  alias Backend.Battlefy
  alias Backend.Battlefy.Match

  @type expanded :: %{
          tournament: Battlefy.Tournament.t(),
          duration: integer,
          standings: [Backend.Battlefy.Standings]
        }
  @spec get_player_count(
          Battlefy.tournament_id()
          | Backend.Battlefy.Tournament.t()
          | %{standings: Backend.Battlefy.Standings.t()}
        ) :: integer
  def get_player_count(%{standings: standings}) do
    standings |> Enum.count()
  end

  def get_player_count(id_or_tournament) do
    id_or_tournament
    |> Battlefy.get_tournament_standings()
    |> Enum.count()
  end

  def get_average_player_count(tournaments) do
    total =
      tournaments
      |> Enum.map(&get_player_count/1)
      |> Enum.sum()

    count = tournaments |> Enum.count()
    total / count
  end

  def get_standings_and_duration(tournament) do
    %{
      tournament: tournament,
      duration: Backend.Battlefy.Tournament.get_duration(tournament),
      standings: Backend.Battlefy.get_tournament_standings(tournament)
    }
  end

  def group_and_get_standings(tournaments) do
    tournaments
    |> Enum.map(&get_standings_and_duration/1)
    |> Enum.filter(fn %{duration: duration} -> duration end)
    |> Enum.group_by(fn tds -> tds.tournament.region end)
  end

  def remove_fewer_rounds(tournaments) do
    tournaments
    |> Enum.filter(fn %{standings: s} -> 256 < s |> Enum.count() end)
  end

  def remove_all_rounds(tournaments) do
    tournaments
    |> Enum.filter(fn %{standings: s} -> 257 > s |> Enum.count() end)
  end

  def get_average_duration_all_rounds(tournaments) do
    tournaments
    |> remove_fewer_rounds()
    |> get_average_duration()
  end

  def get_average_duration_fewer_rounds(tournaments) do
    tournaments
    |> remove_all_rounds()
    |> get_average_duration()
  end

  def get_average_duration([]) do
    0
  end

  def get_average_duration(t = _tournaments_with_meta) do
    count = t |> Enum.count()

    total =
      t
      |> Enum.map(fn twm -> twm.duration end)
      |> Enum.filter(&Util.id/1)
      |> Enum.sum()

    total / count
  end

  def get_number_short(tournaments) do
    tournaments |> Enum.filter(fn %{standings: s} -> 257 > s |> Enum.count() end) |> Enum.count()
  end

  def get_number_full(tournaments) do
    tournaments |> Enum.filter(fn %{standings: s} -> 512 == s |> Enum.count() end) |> Enum.count()
  end

  @spec get_fewest_players(expanded) :: Any
  def get_fewest_players(tournaments) do
    min_max_players(tournaments) |> elem(0)
  end

  @spec get_most_players(expanded) :: Any
  def get_most_players(tournaments) do
    min_max_players(tournaments) |> elem(1)
  end

  @spec min_max_players(expanded) :: Any
  def min_max_players(tournaments) do
    # tournaments |> Enum.map(fn %{standings: s} -> s |> Enum.count() end) |> Enum.min_max()
    tournaments
    |> Enum.map(fn %{standings: s, tournament: t} ->
      {s |> Enum.count(), Backend.MastersTour.create_qualifier_link(t)}
    end)
    |> Enum.min_max_by(fn {num, _} -> num end)
  end

  @spec min_max_duration(expanded) :: Any
  def min_max_duration(tournaments) do
    tournaments
    |> Enum.map(fn %{duration: duration, tournament: t} ->
      {duration, Backend.MastersTour.create_qualifier_link(t)}
    end)
    |> Enum.min_max()
  end

  def get_meta(unfiltered = _tournaments_with_meta) do
    t = unfiltered |> Enum.filter(fn %{duration: duration} -> duration end)
    {fewest, most} = min_max_players(t)
    {{shortest_dur, shortest_link}, {longest_dur, longest_link}} = min_max_duration(t)

    %{
      average_duration: t |> get_average_duration() |> Util.human_duration(),
      average_duration_fewer_rounds:
        t |> get_average_duration_fewer_rounds() |> Util.human_duration(),
      average_duration_all_rounds:
        t |> get_average_duration_all_rounds() |> Util.human_duration(),
      shortest_duration: {Util.human_duration(shortest_dur), shortest_link},
      longest_duration: {Util.human_duration(longest_dur), longest_link},
      avg_players: get_average_player_count(t),
      fewest_players: fewest,
      most_players: most,
      num: t |> Enum.count(),
      num_fewer_rounds: get_number_short(t),
      num_full: get_number_full(t)
    }
  end

  def get_meta_per_region_for_tour(tour_stop) do
    tour_stop
    |> Backend.MastersTour.get_qualifiers_for_tour()
    |> get_meta_per_region()
  end

  def get_meta_per_region(qualifiers) do
    qualifiers
    |> Enum.map(fn t -> Backend.Battlefy.get_tournament(t.id) end)
    |> Backend.BattlefyUtil.group_and_get_standings()
    |> Enum.map(fn {region, tours} -> {region, Backend.BattlefyUtil.get_meta(tours)} end)
  end

  def get_prev_rounds_matches(1, _rounds) do
    0
  end

  @doc """
    Gets the number of matches that happened in previous rounds
    ## Example
      iex> Backend.BattlefyUtil.get_prev_rounds_matches(3, 9)
      384
  """
  def get_prev_rounds_matches(round_number, total_rounds) do
    (get_prev_rounds_matches(round_number - 1, total_rounds) +
       :math.pow(2, total_rounds - round_number + 1))
    |> trunc()
  end

  @doc """
    Gets the match num for a position in a round
    ## Example
      iex> Backend.BattlefyUtil.get_matchnum(5, 3, 9)
      389
      iex> Backend.BattlefyUtil.get_matchnum(88, 1, 9)
      88
  """
  def get_matchnum(pos_in_round, round_number, total_rounds) do
    get_prev_rounds_matches(round_number, total_rounds) + pos_in_round
  end

  @doc """
    Gets the position of a match in a round
    ## Example
      iex> Backend.BattlefyUtil.get_pos_in_round(389, 3, 9)
      5
      iex> Backend.BattlefyUtil.get_pos_in_round(300, 2, 9)
      44
  """
  def get_pos_in_round(match_number, round_number, total_rounds) do
    match_number - get_prev_rounds_matches(round_number, total_rounds)
  end

  def prev_top(_match_number, 1, _total_rounds) do
    nil
  end

  def prev_top(%{match_number: 1}, _, _) do
    nil
  end

  def prev_top(%{match_number: match_number, round_number: round_number}, matches, total_rounds) do
    prev_number = prev_top(match_number, round_number, total_rounds)
    matches |> Match.find(prev_number)
  end

  @doc """
    Gets the matchnum of the match the top player comes from
    ## Example
      iex> Backend.BattlefyUtil.prev_top(389, 3, 9)
      265
      iex> Backend.BattlefyUtil.prev_top(300, 2, 9)
      87
  """
  def prev_top(match_number, round_number, total_rounds) do
    pos_in_round = get_pos_in_round(match_number, round_number, total_rounds)
    get_matchnum(pos_in_round * 2 - 1, round_number - 1, total_rounds)
  end

  def prev_bottom(_match_number, 1, _total_rounds) do
    nil
  end

  def prev_bottom(%{match_number: 1}, _, _) do
    nil
  end

  def prev_bottom(
        %{match_number: match_number, round_number: round_number},
        matches,
        total_rounds
      ) do
    prev_number = prev_bottom(match_number, round_number, total_rounds)
    matches |> Match.find(prev_number)
  end

  @doc """
    Gets the matchnum of the match the bottom player comes from
    ## Example
      iex> Backend.BattlefyUtil.prev_bottom(389, 3, 9)
      266
      iex> Backend.BattlefyUtil.prev_bottom(300, 2, 9)
      88
  """
  def prev_bottom(match_number, round_number, total_rounds) do
    pos_in_round = get_pos_in_round(match_number, round_number, total_rounds)
    get_matchnum(pos_in_round * 2, round_number - 1, total_rounds)
  end

  @doc """
    Gets the matchnum of the match the bottom player comes from
    ## Example
      iex> Backend.BattlefyUtil.next_round_match(481, 5, 9)
      497
      iex> Backend.BattlefyUtil.next_round_match(504, 6, 9)
      508
  """
  def next_round_match(match_number, round_number, total_rounds) do
    pos_in_round = get_pos_in_round(match_number, round_number, total_rounds)
    get_matchnum((pos_in_round / 2) |> Float.ceil() |> trunc(), round_number + 1, total_rounds)
  end

  def get_neighbor(_, round_number, total_rounds) when round_number == total_rounds do
    nil
  end

  @doc """
    Get's the neighboring match that will go to the same next round match.
    ## Example
      iex> Backend.BattlefyUtil.get_neighbor(258, 2, 9)
      257
      iex> Backend.BattlefyUtil.get_neighbor(257, 2, 9)
      258
      iex> Backend.BattlefyUtil.get_neighbor(331, 2, 9)
      332
  """
  def get_neighbor(match_number, _, _) do
    case rem(match_number, 2) do
      1 -> match_number + 1
      0 -> match_number - 1
    end
  end
end
