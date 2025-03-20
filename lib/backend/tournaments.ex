defmodule Backend.Tournaments do
  alias Backend.Battlefy
  alias Backend.Battlefy.Tournament, as: BattlefyTournament
  alias Backend.Tournaments.Tournament

  @type tournament_tuple :: {tournament_source :: String.t(), tournament_id :: String.t()}

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
end
