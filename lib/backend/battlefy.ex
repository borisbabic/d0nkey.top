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
  @type get_matches_opt :: {:round, integer()}
  @type get_matches_options :: [get_matches_opt]
  @type get_tournament_matches_opt :: {:stage, integer()} | get_matches_opt
  @type get_tournament_matches_options :: [get_tournament_matches_opt]

  @spec get_tournament_standings(Tournament.t() | %{stage_ids: [stage_id]}) :: [Standings.t()]
  def get_tournament_standings(%{stage_ids: stage_ids}) do
    stage_ids
    |> List.last()
    |> get_stage_standings()
  end

  @spec get_tournament_standings(tournament_id) :: [Standings.t()]
  def get_tournament_standings(tournament_id) do
    tournament_id
    |> get_tournament()
    |> get_tournament_standings()
  end

  @spec get_stage_standings(stage_id) :: [Standings.t()]
  def get_stage_standings(stage_id) do
    Api.get_standings(stage_id)
  end

  @spec get_tournament(tournament_id) :: Tournament.t()
  def get_tournament(tournament_id) do
    Api.get_tournament(tournament_id)
  end

  def get_tournament_matches(id_od_tournament, opts \\ [])

  @spec get_tournament_matches(
          Tournament.t() | %{stage_ids: [stage_id]},
          get_tournament_matches_options
        ) :: [Match.t()]
  def get_tournament_matches(%{stage_ids: stage_ids}, opts) do
    stage_ids
    |> Enum.at(opts[:stage] || 0)
    |> get_matches(Util.reject_keys(opts, [:stage]))
  end

  @spec get_tournament_matches(tournament_id, get_tournament_matches_options) :: [Match.t()]
  def get_tournament_matches(tournament_id, opts) do
    tournament_id
    |> get_tournament()
    |> get_tournament_matches(opts)
  end

  @spec get_matches(stage_id, get_matches_options) :: [Match.t()]
  def get_matches(stage_id, opts \\ []) do
    Api.get_matches(stage_id, opts)
  end
end
