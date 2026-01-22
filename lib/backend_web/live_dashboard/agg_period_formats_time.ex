defmodule BackendWeb.LiveDashboard.AggregationPeriodFormatTimePage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  @impl true
  def menu_link(_, _) do
    {:ok, "Agg Period Format Time"}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <.live_table
        id="agg-period-format-time-table"
        dom_id="agg-period-format-time-table"
        page={@page}
        title={"Aggregation Period Formats"}
        row_fetcher={&fetch_rows/2}
        rows_name="aggregated period formats"
      >
        <:col field={:time} sortable={:desc}/>
        <:col field={:format} sortable={:asc}/>
        <:col field={:period} />
      </.live_table>
    """
  end

  def fetch_rows(params, _node) do
    %{limit: limit, sort_by: sort_by, sort_dir: direction} = params

    all_results =
      Hearthstone.DeckTracker.aggregated_periods_formats_time()
      |> Enum.map(fn {period, format, time} ->
        %{
          period: period,
          format: format,
          time: time
        }
      end)
      |> search(params)
      |> Enum.sort_by(&to_string(Map.get(&1, sort_by)), direction)

    results = all_results |> Enum.take(limit)
    {results, all_results |> Enum.count()}
  end

  def search(results, %{search: search}) when is_binary(search) do
    results
    |> Enum.filter(fn %{period: period} -> String.downcase(period) =~ String.downcase(search) end)
  end

  def search(results, _params), do: results
end
