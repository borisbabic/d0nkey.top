defmodule Backend.Battlefy.LineupFetcher do
  @moduledoc false
  use Oban.Worker, queue: :battlefy_lineups, unique: [period: 360]
  alias Backend.Battlefy
  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchTeam
  alias Backend.Infrastructure.BattlefyCommunicator, as: Api

  @impl Oban.Worker
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

  @spec enqueue_jobs(Tournament.t() | String.t()) :: {:ok, [Oban.Job.t()]} | {:error, any()}
  def enqueue_jobs(%Tournament{stages: stages, id: id}) when is_list(stages) do
    stages
    |> Enum.flat_map(&Battlefy.get_matches(&1, round: 1))
    |> enqueue_matches(id)
  end

  def enqueue_jobs(id) when is_binary(id), do: Battlefy.get_tournament(id) |> enqueue_jobs()

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
