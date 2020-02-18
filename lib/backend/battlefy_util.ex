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

  def get_meta(t = _tournaments_with_meta) do
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
end
