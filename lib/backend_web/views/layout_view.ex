defmodule BackendWeb.LayoutView do
  use BackendWeb, :view
  import FunctionComponents.LayoutComponent

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

  def render_battlefy_link(assigns) do
    ~H"""
    """
  end

  def show_mt(conn, tour_stop) do
    case Backend.Battlefy.get_tour_stop_id(tour_stop) do
      {:error, _} ->
        ""

      {:ok, id} ->
        name =
          case Backend.MastersTour.TourStop.get(tour_stop) do
            %{display_name: dn} when is_binary(dn) -> dn
            %{id: id} -> id
            _ -> tour_stop
          end

        assigns = %{conn: conn, name: name, id: id}

        ~H"""
          <a class="navbar-item" href={Routes.battlefy_path(@conn, :tournament, @id)}><%= @name %> </a>
        """
    end
  end

  def grandmasters(conn) do
    link = Routes.grandmasters_path(conn, :grandmasters_season, "2020_2")

    assigns = %{link: link}

    ~H"""
      <a class="navbar-item" href={@link}>Grandmasters</a>
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

  def current_dreamhack(%Plug.Conn{} = _conn) do
    case Dreamhack.current() do
      current = [_ | _] ->
        current_dreamhack(%{current: current})

      _ ->
        ""
    end
  end

  def current_dreamhack(assigns) do
    ~H"""
      <div class="navbar-item has-dropdown is-hoverable">
        <div class="navbar-link">
          DreamHack
        </div>

        <div class="navbar-dropdown">
          <%= for {tour, id} <- @current do %>
            <a class="navbar-item" href={~p"/battlefy/tournament/#{id}"}>
              <%= tour %>
            </a>
          <% end %>
        </div>
      </div>
    """
  end

  def show_lobby_legends?() do
    Backend.LobbyLegends.LobbyLegendsSeason.current(1, 48)
  end

  def show_fantasy?() do
    false &&
      (ongoing_dreamhack_fantasy?() ||
         ongoing_mt_fantasy?() ||
         ongoing_lobby_legends_fantasy?() ||
         highlight_fantasy_for_gm?())
  end

  def twitchbot?(user) do
    with %{twitch_id: twitch_id} when not is_nil(twitch_id) <- user,
         %{twitch_login: twitch_login} <- Backend.Streaming.streamer_by_twitch_id(twitch_id),
         chats <- Application.get_env(:backend, :twitch_bot_chats) do
      twitch_login in chats
    else
      _ -> false
    end
  end

  defp ongoing_lobby_legends_fantasy?(),
    do: !!Backend.LobbyLegends.LobbyLegendsSeason.current(120, 60)

  defp ongoing_mt_fantasy?(), do: !!Backend.MastersTour.TourStop.get_current(120, 60)
  defp ongoing_dreamhack_fantasy?(), do: Enum.any?(Dreamhack.current_fantasy())
  defp highlight_fantasy_for_gm?(), do: false

  @spec enable_nitropay?(Plug.Conn.t()) :: boolean
  def enable_nitropay?(%{params: %{"nitropay_test" => "yes"}}), do: true
  def enable_nitropay?(_), do: Application.get_env(:backend, :enable_nitropay, false)

  @spec enable_adsense?(Plug.Conn.t()) :: boolean
  def enable_adsense?(conn) do
    Backend.AdsTxtCache.config()
    |> Enum.find_value(false, fn {host, %{enable_adsense: enable}} ->
      conn.host =~ host && enable
    end)
  end

  @spec hide_ads?(Plug.Conn.t()) :: boolean
  def hide_ads?(conn) do
    conn
    |> user()
    |> Backend.UserManager.User.hide_ads?()
  end

  @spec show_ads?(Plug.Conn.t()) :: boolean
  def show_ads?(conn), do: !hide_ads?(conn)

  @spec space_for_ads?(Plug.Conn.t()) :: boolean
  def space_for_ads?(conn), do: enable_nitropay?(conn) && show_ads?(conn)

  def container_classes(conn) do
    if enable_nitropay?(conn) && show_ads?(conn) do
      "container is-fluid space-for-ads"
    else
      "container is-fluid"
    end
  end

  def nitropay_demo?() do
    Application.get_env(:backend, :nitropay_demo, true)
  end
end
