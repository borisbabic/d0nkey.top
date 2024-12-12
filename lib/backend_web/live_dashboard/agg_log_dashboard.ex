defmodule BackendWeb.LiveDashboard.AggregationLogPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  @impl true
  def menu_link(_, _) do
    {:ok, "Agg Log"}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <.live_table
        id="agg-log-table"
        dom_id="agg-log-table"
        page={@page}
        title={"Aggregation Log"}
        row_fetcher={&fetch_rows/2}
        rows_name="log entries"
      >
        <:col field={:inserted_at} sortable={:desc}/>
        <:col field={:regions} />
        <:col field={:formats} />
        <:col field={:periods} />
        <:col field={:ranks} />
      </.live_table>
    """
  end

  def fetch_rows(params, _node) do
    %{limit: limit, sort_by: sort_by, sort_dir: direction} = params

    log_entries =
      Hearthstone.DeckTracker.get_latest_agg_log_entries(limit, {direction, sort_by})
      |> Enum.map(fn e ->
        %{
          inserted_at: e.inserted_at,
          regions: Enum.join(e.regions, "|"),
          ranks: Enum.join(e.ranks, "|"),
          periods: Enum.join(e.periods, "|"),
          formats: Enum.join(e.formats, "|")
        }
      end)

    {log_entries, Hearthstone.DeckTracker.agg_log_count()}
  end
end
