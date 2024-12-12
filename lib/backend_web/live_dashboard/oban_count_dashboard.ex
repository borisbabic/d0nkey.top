defmodule BackendWeb.LiveDashboard.ObanCountPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder
  import Ecto.Query

  @impl true
  def menu_link(_, _) do
    {:ok, "Oban Count"}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <.live_table
        id="oban-count-table"
        dom_id="oban-count-table"
        page={@page}
        title={"Oban Counts"}
        row_fetcher={&fetch_rows/2}
        rows_name="queue-states"
      >
        <:col field={:queue} sortable={:asc}/>
        <:col field={:state} sortable={:asc} />
        <:col field={:count} sortable={:desc} />
      </.live_table>
    """
  end

  def fetch_rows(params, _node) do
    %{limit: limit, sort_by: sort_by, sort_dir: direction} = params

    query =
      from oj in "oban_jobs",
        select: %{queue: oj.queue, state: oj.state, count: fragment("count(*)")},
        group_by: [1, 2],
        order_by: {^direction, ^sort_by}

    all = Backend.Repo.all(query)
    {Enum.take(all, limit), Enum.count(all)}
  end
end
