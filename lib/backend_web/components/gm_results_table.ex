defmodule Components.GMResultsTable do
  @moduledoc false
  use Surface.Component
  alias Components.GMProfileLink
  alias Backend.Grandmasters.Response.Match

  prop(week, :string)
  prop(region, :string)
  prop(match_filter, :fun, default: nil)

  def render(assigns) do
    ~F"""
        <table class="table is-fullwidth is-striped">
          <thead>
            <tr>
              <th>Stage</th>
              <th>Top</th>
              <th>Results</th>
              <th>Bottom</th>
            </tr>
          </thead>
          <tbody>
          <tr :for={match <- matches(@region, @week) |> filter(@match_filter) |> sort()} >
              <td>{Backend.Grandmasters.bracket(match.bracket_id).name}</td>
              <td><GMProfileLink week={"#{@week}"} gm={Match.match_info(match).top} /></td>
              <td><a href={"#{match_link(match)}"}>{Match.match_info(match).score}</a></td>
              <td><GMProfileLink week={"#{@week}"} gm={Match.match_info(match).bottom} /></td>
            </tr>
          </tbody>
        </table>

    """
  end

  def match_link(%{id: id}), do: "https://hearthstone.blizzard.com/en-us/esports/match/#{id}"
  def matches(region, week), do: Backend.Grandmasters.region_matches(region, week)
  def filter(matches, fun) when is_function(fun), do: matches |> Enum.filter(fun)
  def filter(matches, _), do: matches

  def sort(matches) do
    matches
    |> Enum.sort_by(& &1.start_date, :desc)
    |> Enum.sort_by(& &1.bracket_id, :desc)
  end
end
