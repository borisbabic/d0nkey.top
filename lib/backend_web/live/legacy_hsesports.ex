defmodule BackendWeb.LegacyHSEsportsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  def render(assigns) do
    ~F"""
      <div class="title is-2">Archive of old hsesports pages</div>
      <ul>
          <li> <a href={"#{Routes.masters_tour_path(BackendWeb.Endpoint, :invited_players) }"}>Invited Players</a></li>
          <li> <a href={"#{Routes.masters_tour_path(BackendWeb.Endpoint, :qualifiers)}"}>Qualifiers</a></li>
          <li> <a href={"#{Routes.masters_tour_path(BackendWeb.Endpoint, :qualifier_stats)}"}>Qualifier Stats</a></li>
          <li> <a href={"#{Routes.masters_tour_path(BackendWeb.Endpoint, :points)}"}>Points</a></li>
          <li> <a href={"#{Routes.masters_tour_path(BackendWeb.Endpoint, :tour_stops)}"}>Tour Stops</a></li>
          <li> <a href={"#{Routes.masters_tour_path(BackendWeb.Endpoint, :masters_tours_stats)}"}>Stats</a></li>
      </ul>
    """
  end
end
