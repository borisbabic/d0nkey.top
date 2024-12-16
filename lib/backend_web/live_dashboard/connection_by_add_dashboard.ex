defmodule BackendWeb.LiveDashboard.ClientAddrConnPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder
  import Ecto.Query

  @impl true
  def menu_link(_, _) do
    {:ok, "Client Addr Conn"}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <.live_table
        id="client-addr-conn-table"
        dom_id="client-addr-conn-table"
        page={@page}
        title={"Client Addr Conn"}
        row_fetcher={&fetch_rows/2}
        rows_name="client addrs"
      >
        <:col field={:client_addr} sortable={:desc} />
        <:col field={:count} sortable={:desc}/>
      </.live_table>
    """
  end

  def fetch_rows(params, _node) do
    %{limit: limit, sort_by: sort_by, sort_dir: direction} = params

    query =
      from psa in "pg_stat_activity",
        select: %{
          client_addr: fragment("?::text", psa.client_addr) |> selected_as(:client_addr),
          count: fragment("count(*)") |> selected_as(:count)
        },
        group_by: selected_as(:client_addr),
        order_by: {^direction, selected_as(^sort_by)}

    all = Backend.Repo.all(query)
    {Enum.take(all, limit), Enum.count(all)}
  end
end
