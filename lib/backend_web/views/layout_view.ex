defmodule BackendWeb.LayoutView do
  use BackendWeb, :view

  def current_mt(conn) do
    today = Date.utc_today()

    case {today.year, today.month, today.day} do
      {2020, 6, day} when day > 11 and day < 18 -> show_mt(conn, :Jönköping)
      _ -> ""
    end
  end

  def show_mt(conn, tour_stop) do
    case Backend.Battlefy.get_tour_stop_id(tour_stop) do
      {:error, _} ->
        ""

      {:ok, id} ->
        assigns = %{conn: conn, tour_stop: tour_stop, id: id}

        ~E"""
          <a class="navbar-item" href='<%=Routes.battlefy_path(@conn, :tournament, id) %>'><%= tour_stop %> </a>
        """
    end
  end
end
