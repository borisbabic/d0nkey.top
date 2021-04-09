defmodule Backend.Grandmasters.LineupFetcher do
  @moduledoc false
  use Oban.Worker, queue: :grandmasters_lineups, unique: [period: 300]

  alias Backend.Infrastructure.GrandmastersCommunicator, as: Api
  alias Backend.Grandmasters.Response
  alias Backend.Blizzard
  alias Ecto.Multi
  alias Backend.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"stage_title" => stage_title}}) do
    save_lineups(stage_title)
  end

  def save_lineups(stage_title) do
    with r = %{requested_season: rs} <- Api.get_gm(),
         decklists <- r |> Response.decklists(stage_title) do
      tournament_id = Blizzard.gm_lineup_tournament_id({rs.year, rs.season}, stage_title)

      decklists
      |> Enum.map(fn {%{name: name}, codes} ->
        Backend.Hearthstone.get_or_create_lineup(
          tournament_id,
          "grandmasters",
          name,
          codes
        )
      end)

      :ok
    else
      _ -> :error
    end
  end

  def enqueue_job(stage_title) do
    %{"stage_title" => stage_title}
    |> new()
    |> Oban.insert()
  end
end
