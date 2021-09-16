defmodule BackendWeb.BattlefySearchProvider do
  @behaviour OmniBar.SearchProvider
  alias OmniBar.Result
  alias BackendWeb.Router.Helpers, as: Routes

  def search(term, callback) do
    term
    |> String.trim()
    |> URI.parse()
    |> case do
      %{host: "battlefy.com", path: path} -> handle_battlefy_path(path, term, callback)
      _ -> true
    end
  end

  def handle_battlefy_path(path, term, callback) do
    [
      tournament_standings(path, term),
      match(path, term),
      organizer(path, term)
    ]
    |> Enum.filter(& &1)
    |> Enum.each(callback)
  end

  defp tournament_standings(path, term) do
    path
    |> String.split("/")
    |> case do
      [_empty, _org, _tour, tournament_id | _] ->
        %Result{
          search_term: term,
          display_value: "View tournament standings",
          priority: 0.8,
          result_id: "battlefy_tournament_standings_result",
          link: Routes.battlefy_path(BackendWeb.Endpoint, :tournament, tournament_id)
        }

      _ ->
        nil
    end
  end

  defp match(path, term) do
    path
    |> String.split("/")
    |> case do
      [_empty, _org, _tour, tournament_id, "stage", _stage_id, "match", match_id] ->
        %Result{
          search_term: term,
          display_value: "View match",
          priority: 0.9,
          result_id: "battlefy_tournament_match_result",
          link:
            Routes.live_path(
              BackendWeb.Endpoint,
              BackendWeb.BattlefyMatchLive,
              tournament_id,
              match_id
            )
        }

      _ ->
        nil
    end
  end

  defp organizer(path, term) do
    path
    |> String.split("/")
    |> case do
      [_empty, org | _] ->
        %Result{
          search_term: term,
          display_value: "View organizer tournaments",
          priority: 0.5,
          result_id: "battlefy_organizier_tournament_results",
          link:
            Routes.battlefy_path(BackendWeb.Endpoint, :organization_tournaments, %{"slug" => org})
        }

      _ ->
        nil
    end
  end
end
