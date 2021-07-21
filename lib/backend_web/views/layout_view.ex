defmodule BackendWeb.LayoutView do
  use BackendWeb, :view

  def current_mt(conn) do
    case Backend.MastersTour.TourStop.get_current() do
      nil -> ""
      ts -> show_mt(conn, ts)
    end

    #    today = Date.utc_today()
    #
    #    case {today.year, today.month, today.day} do
    #      {2020, 6, day} when day > 11 and day < 18 -> show_mt(conn, :"Jönköping")
    #      _ -> ""
    #    end
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

  def grandmasters(conn) do
    link = Routes.grandmasters_path(conn, :grandmasters_season, "2020_2")

    ~E"""
      <a class="navbar-item" href='<%= link %>'>Grandmasters</a>
    """
  end

  def render("navbar.html", %{handle_user: true, conn: conn}) do
    user =
      conn
      |> Guardian.Plug.current_resource()
      |> case do
        %{battletag: bt} -> bt
        _ -> nil
      end

    render("navbar.html", %{user: user, conn: conn})
  end

  def current_dreamhack(conn) do
    case Dreamhack.current() do
      current = [_ | _] ->
        ~E"""
         <div class="navbar-item has-dropdown is-hoverable">
           <div class="navbar-link">
             DreamHack
           </div>

           <div class="navbar-dropdown">
            <%= for {tour, id} <- current do %>
              <a class="navbar-item" href='<%=Routes.battlefy_path(conn, :tournament, id)%>'><%= tour %></a>
            <% end %>
           </div>
         </div>
        """

      _ ->
        ""
    end
  end
end
