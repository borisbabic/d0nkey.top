defmodule Backend.BattlefyUtil do
  alias Backend.Battlefy

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

  def get_num_short(tournaments) do
    tournaments |> Enum.filter(fn %{standings: s} -> 257 > s |> Enum.count() end) |> Enum.count()
  end

  def get_num_full(tournaments) do
    tournaments |> Enum.filter(fn %{standings: s} -> 512 == s |> Enum.count() end) |> Enum.count()
  end

  def get_fewest_players(tournaments) do
    min_max_players(tournaments) |> elem(0)
  end

  def get_most_players(tournaments) do
    min_max_players(tournaments) |> elem(1)
  end

  def min_max_players(tournaments) do
    tournaments |> Enum.map(fn %{standings: s} -> s |> Enum.count() end) |> Enum.min_max()
  end

  def get_meta(unfiltered = _tournaments_with_meta) do
    t = unfiltered |> Enum.filter(fn %{duration: duration} -> duration end)
    {fewest, most} = min_max_players(t)

    %{
      average_duration: t |> get_average_duration() |> Util.human_duration(),
      average_duration_fewer_rounds:
        t |> get_average_duration_fewer_rounds() |> Util.human_duration(),
      average_duration_all_rounds:
        t |> get_average_duration_all_rounds() |> Util.human_duration(),
      avg_players: get_average_player_count(t),
      fewest_players: fewest,
      most_players: most,
      num: t |> Enum.count(),
      num_fewer_rounds: get_num_short(t),
      num_full: get_num_full(t)
    }
  end

  def get_meta_per_region_for_tour(tour_stop) do
    Backend.MastersTour.get_qualifiers_for_tour(tour_stop)
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
  def get_prev_rounds_matches(round_num, total_rounds) do
    (get_prev_rounds_matches(round_num - 1, total_rounds) +
       :math.pow(2, total_rounds - round_num + 1))
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
  def get_matchnum(pos_in_round, round_num, total_rounds) do
    get_prev_rounds_matches(round_num, total_rounds) + pos_in_round
  end

  @doc """
    Gets the position of a match in a round
    ## Example
      iex> Backend.BattlefyUtil.get_pos_in_round(389, 3, 9)
      5
      iex> Backend.BattlefyUtil.get_pos_in_round(300, 2, 9)
      44
  """
  def get_pos_in_round(match_num, round_num, total_rounds) do
    match_num - get_prev_rounds_matches(round_num, total_rounds)
  end

  def prev_top(_match_num, 1, _total_rounds) do
    nil
  end

  @doc """
    Gets the matchnum of the match the top player comes from
    ## Example
      iex> Backend.BattlefyUtil.prev_top(389, 3, 9)
      265
      iex> Backend.BattlefyUtil.prev_top(300, 2, 9)
      87
  """
  def prev_top(match_num, round_num, total_rounds) do
    pos_in_round = get_pos_in_round(match_num, round_num, total_rounds)
    get_matchnum(pos_in_round * 2 - 1, round_num - 1, total_rounds)
  end

  def prev_bottom(_match_num, 1, _total_rounds) do
    nil
  end

  @doc """
    Gets the matchnum of the match the bottom player comes from
    ## Example
      iex> Backend.BattlefyUtil.prev_bottom(389, 3, 9)
      266
      iex> Backend.BattlefyUtil.prev_bottom(300, 2, 9)
      88
  """
  def prev_bottom(match_num, round_num, total_rounds) do
    pos_in_round = get_pos_in_round(match_num, round_num, total_rounds)
    get_matchnum(pos_in_round * 2, round_num - 1, total_rounds)
  end
end
