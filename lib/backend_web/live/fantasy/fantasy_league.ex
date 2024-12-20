defmodule BackendWeb.FantasyLeagueLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Fantasy
  alias Components.FantasyLeague
  import BackendWeb.LiveHelpers

  data(user, :any)
  data(league_id, :string)
  data(league, :any)

  def mount(params, session, s) do
    socket = s |> assign_defaults(session) |> assign_league(params |> put_user_in_context())
    # TODO REPLACE THIS
    # BackendWeb.Endpoint.subscribe("entity_leagues_#{socket.assigns.league_id}")
    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
      <div>
        <FantasyLeague id={"fantasy_league_#{@league_id}"} league={@league} />
      </div>
    """
  end

  defp assign_league(socket, %{"league_id" => league_id}), do: socket |> assign_league(league_id)

  defp assign_league(socket, league_id) when is_binary(league_id) or is_integer(league_id) do
    socket
    |> assign(league_id: league_id, league: get_league(league_id) || %{})
  end

  defp get_league(league_id), do: Fantasy.get_league(league_id)

  def handle_info(
        %{payload: %{id: payload_id, table: "leagues"}},
        s = %{assigns: %{league_id: league_id}}
      ) do
    socket =
      if to_string(payload_id) == to_string(league_id) do
        s |> assign_league(league_id)
      else
        s
      end

    {:noreply, socket}
  end
end
