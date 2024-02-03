defmodule Backend.Grandmasters.LineupFetcher do
  @moduledoc false
  use Oban.Worker, queue: :grandmasters_lineups, unique: [period: 300]

  alias Backend.Infrastructure.GrandmastersCommunicator, as: Api
  alias Backend.Grandmasters.Response
  alias Backend.Blizzard

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"stage_title" => stage_title}}) do
    save_lineups(stage_title)
  end

  def save_lineups(stage_title) do
    with {:ok, response} <- Api.get_gm() do
      save_lineups(response, stage_title)
    end
  end

  def save_lineups(r = %{requested_season: rs}, stage_title) do
    decklists = r |> Response.latest_decklists(stage_title)
    tournament_id = Blizzard.gm_lineup_tournament_id({rs.year, rs.season}, stage_title)
    save_decklists(decklists, tournament_id)
    :ok
  end

  def save_lineups(_, _), do: :error

  def save_decklists(decklists, tournament_id, source \\ "grandmasters")
      when is_list(decklists) do
    Enum.map(decklists, fn {%{name: name}, codes} ->
      Backend.Hearthstone.get_or_create_lineup(
        tournament_id,
        source,
        name,
        codes
      )
    end)
  end

  def enqueue_job(stage_title) do
    %{"stage_title" => stage_title}
    |> new()
    |> Oban.insert()
  end
end
