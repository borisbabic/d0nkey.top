defmodule BackendWeb.LiveDashboard.GamePerMinPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder
  import Ecto.Query

  @impl true
  def menu_link(_, _) do
    {:ok, "Games per min"}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <.live_table
        id="game-per-min-table"
        dom_id="game-per-min-table"
        page={@page}
        title={"Game per min"}
        row_fetcher={&fetch_rows/2}
        rows_name="minutes"
      >
        <:col field={:minute} sortable={:desc}/>
        <:col field={:count} sortable={:desc} />
      </.live_table>
    """
  end

  def fetch_rows(params, _node) do
    %{limit: limit, sort_by: sort_by, sort_dir: direction} = params
    minutes_ago = -1 * (limit - 1)
    b = NaiveDateTime.utc_now() |> Timex.shift(minutes: minutes_ago)
    cutoff = NaiveDateTime.new!(b.year, b.month, b.day, b.hour, b.minute, 0)

    query =
      from g in Hearthstone.DeckTracker.Game,
        select: %{
          minute: fragment("DATE_TRUNC('minute', ?)", g.inserted_at) |> selected_as(:minute),
          count: fragment("count(*)") |> selected_as(:count)
        },
        where: g.inserted_at >= ^cutoff,
        group_by: [selected_as(:minute)],
        order_by: {^direction, selected_as(^sort_by)}

    all = Backend.Repo.all(query)
    {Enum.take(all, limit), Enum.count(all)}
  end
end
