defmodule Backend.Battlefy do
  alias Backend.Infrastructure.BattlefyCommunicator, as: Api
  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Standings

  # 192 = 24 (length of id) * 8 (bits in a byte)
  @type battlefy_id :: <<_::192>>
  @type tournament_id :: battlefy_id
  @type user_id :: battlefy_id
  @type team_id :: battlefy_id
  @type stage_id :: battlefy_id

  @spec get_tournament_standings(Tournament.t() | %{stage_ids: [stage_id]}) :: [Standings.t()]
  def get_tournament_standings(%{stage_ids: stage_ids}) do
    stage_ids
    |> List.last()
    |> get_stage_standings()
  end

  @spec get_tournament_standings(tournament_id) :: [Standings.t()]
  def get_tournament_standings(tournament_id) do
    tournament = get_tournament(tournament_id)
    get_tournament_standings(tournament)
  end

  @spec get_stage_standings(stage_id) :: [Standings.t()]
  def get_stage_standings(stage_id) do
    Api.get_standings(stage_id)
  end

  @spec get_tournament(tournament_id) :: Tournament.t()
  def get_tournament(tournament_id) do
    Api.get_tournament(tournament_id)
  end
end
