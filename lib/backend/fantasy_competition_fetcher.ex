defmodule Backend.FantasyCompetitionFetcher do
  alias Backend.Fantasy.Competition.Participant
  # alias Backend.MastersTour.TourStop
  alias Backend.Battlefy
  @spec get_participants(League.t()) :: [Participant.t()]
  def get_participants(%{competition_type: "masters_tour"}) do
    battletfy_id = "6021753028f37678cb6840bc"
    battletfy_id |> get_battlefy_participants()
  end

  defp get_battlefy_participants(tournament_id) do
    tournament_id
    |> Battlefy.get_participants()
    |> Enum.map(fn p ->
      %Participant{
        name: p.name
      }
    end)
  end
end
