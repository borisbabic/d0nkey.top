defmodule Backend.Leaderboards.PageFetcher do
  @moduledoc "Fetches leaderboard pages and retries failures"
  use Oban.Worker, queue: :leaderboards_pages_fetching, unique: [period: 300]
  alias Backend.Leaderboards
  alias Hearthstone.Leaderboards.Api
  alias Hearthstone.Leaderboards.Response

  def perform(%Oban.Job{args: %{"season_db_id" => db_id, "page_num" => num}}) do
    season = Leaderboards.season(db_id)

    case Api.get_page(season, num) do
      {:ok, %{leaderboard: %{rows: rows = [_ | _]}}} ->
        Leaderboards.handle_rows(rows, season)
        :ok

      {:ok, response} ->
        {:error, {:got_ok_but_bad_response, response}}

      r ->
        r
    end
  end

  def create_args(%{id: id}, num), do: %{"season_db_id" => id, "page_num" => num}

  def enqueue_all(
        %Response{season: season, leaderboard: %{pagination: %{total_pages: tot}}},
        max_page_num \\ nil,
        first_page \\ 1
      ) do
    with {:ok, season = %{id: id}} when is_integer(id) <- Leaderboards.get_season(season) do
      for page_num <- first_page..last_page(tot, max_page_num) do
        create_args(season, page_num)
        |> new()
        |> Oban.insert()
      end
    end
  end

  def last_page(from_response, _from_arg = nil), do: from_response
  def last_page(from_response, from_arg), do: min(from_response, from_arg)
end
