defmodule Components.GMResultsTable do
  @moduledoc false
  use Surface.Component
  alias Components.GMProfileLink
  alias Backend.Grandmasters.Response.Match

  prop(week, :string)
  prop(region, :string)
  prop(match_filter, :fun, default: nil)

  def render(assigns) do
    ~H"""
        <table class="table is-fullwidth is-striped"> 
          <thead>
            <tr>
              <th>Top</th>
              <th>Results</th>
              <th>Bottom</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={{ match = %{competitors: [top, bottom]} <- Backend.Grandmasters.region_matches(@region, @week) |> filter(@match_filter)}}>
              <td><GMProfileLink week="{{ @week }}" gm={{top}} /></td>
              <td>{{ match |> Match.score() }}</td>
              <td><GMProfileLink week="{{ @week }}" gm={{bottom}} /></td>
            </tr>
          </tbody>
        </table>

    """
  end

  def filter(matches, fun) when is_function(fun), do: matches |> Enum.filter(fun)
  def filter(matches, _), do: matches
end
