defmodule Backend.Battlefy.LineupFetcher do
  @moduledoc false
  use Oban.Worker, queue: :battlefy_lineups, unique: [period: 3600]
  alias Backend.Battlefy
  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.Team
  alias Backend.Battlefy.MatchTeam
  alias Backend.Infrastructure.BattlefyCommunicator, as: Api

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "tournament_id" => tournament_id,
          "stage_ids" => stage_ids
        }
      }) do
    enqueue_missing_matches(tournament_id, stage_ids)
    :ok
  end

  def perform(%Oban.Job{args: %{"match_id" => match_id, "tournament_id" => tournament_id}}) do
    with {:ok, match} <- Api.get_match(match_id) do
      fetch(tournament_id, match)
    end

    :ok
  end

  @spec fetch(any, Backend.Battlefy.Match.t()) :: nil | {:error, any} | {:ok, any}
  def fetch(tournament_id, match = %Match{}) do
    deckstrings = Api.get_match_deckstrings(tournament_id, match.id)
    insert(tournament_id, match.top, deckstrings.top)
    insert(tournament_id, match.bottom, deckstrings.bottom)
  end

  def insert(tournament_id, mt = %MatchTeam{team: _}, deckstrings = [_ | _]) do
    Backend.Hearthstone.get_or_create_lineup(
      tournament_id,
      "battlefy",
      MatchTeam.get_name(mt),
      deckstrings
    )
  end

  def insert(_, _, _), do: nil

  @spec enqueue_jobs(Tournament.t() | Battlefy.tournament_id()) ::
          {:ok, [Oban.Job.t()]} | {:ok, [any()]} | {:error, any()}
  def enqueue_jobs(%Tournament{stages: stages, id: id}) when is_list(stages) do
    {:ok,
     stages
     |> Enum.flat_map(&Battlefy.get_matches(&1, round: 1))
     |> enqueue_matches(id)}
  end

  def enqueue_jobs(id) when is_binary(id) do
    case Battlefy.get_tournament(id) do
      %Tournament{} = tournament -> enqueue_jobs(tournament)
      nil -> {:error, :tournament_not_found}
    end
  end

  def enqueue_jobs(_), do: {:error, :tournament_not_found}

  def async_enqueue_missing_lineups(
        tournament,
        standings,
        lineups
      ) do
    Task.start(fn ->
      lineup_names = Enum.map(lineups, & &1.name)

      if Enum.any?(standings, &(Team.player_or_team_name(&1.team) not in lineup_names)) do
        enqueue_missing_jobs(tournament)
      end
    end)
  end

  defp enqueue_missing_jobs(%{stages: stages, id: id}) do
    stage_ids = Enum.map(stages, & &1.id)

    {
      :ok,
      %{"stage_ids" => stage_ids, "tournament_id" => id}
      |> new()
      |> Oban.insert()
    }
  end

  defp enqueue_missing_jobs(_), do: :error

  @spec enqueue_missing_matches(Tournament.t(), [String.t()]) :: any()
  def enqueue_missing_matches(%{stages: stages, id: id}),
    do: enqueue_missing_matches(id, stages)

  @spec enqueue_missing_matches(String.t(), String.t()) :: any()
  defp enqueue_missing_matches(tournament_id, stages_or_stage_ids)
       when is_list(stages_or_stage_ids) do
    lineup_names = lineup_names(tournament_id)
    names_map_set = MapSet.new([nil | lineup_names])

    #### using reduces and acc so we can update the known names so we don't spam
    {matches, _} =
      stages_or_stage_ids
      |> Enum.reduce({[], names_map_set}, fn stage, acc ->
        Battlefy.get_matches(stage, round: 1)
        |> Enum.reduce(acc, fn %{top: top, bottom: bottom} = match, {matches, handled_names} ->
          top_name = MatchTeam.get_name(top)
          bottom_name = MatchTeam.get_name(bottom)

          missing_top? = !MapSet.member?(handled_names, top_name)
          missing_bottom? = !MapSet.member?(handled_names, bottom_name)

          if missing_top? or missing_bottom? do
            {
              [match | matches],
              handled_names
              |> MapSet.put(top_name)
              |> MapSet.put(bottom_name)
            }
          else
            {matches, handled_names}
          end
        end)
      end)

    {:ok, enqueue_matches(matches, tournament_id)}
  end

  defp lineup_names(tournament_id) do
    Backend.Hearthstone.get_lineups("battlefy", tournament_id)
    |> Enum.map(& &1.name)
  end

  defp enqueue_matches([], _), do: {:error, :no_matches}

  defp enqueue_matches(matches, id) do
    {
      :ok,
      matches
      |> Enum.map(&(%{"match_id" => &1.id, "tournament_id" => id} |> new()))
      |> Enum.map(&Oban.insert/1)
    }
  end

  def fetch_async_if_missing(id_or_tournament) do
    Task.start(fn ->
      if !Battlefy.has_lineups?(id_or_tournament) do
        enqueue_jobs(id_or_tournament)
      end
    end)
  end

  def fetch_async(id_or_tournament), do: Task.start(fn -> enqueue_jobs(id_or_tournament) end)
end
