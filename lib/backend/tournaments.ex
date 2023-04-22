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
end
