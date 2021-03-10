defmodule BackendWeb.FantasyLeagueLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Fantasy
  alias Components.FantasyLeague
  import BackendWeb.LiveHelpers

  data(user, :any)
  data(league_id, :string)
  data(league, :any)

  def mount(params, session, s) do
    socket = s |> assign_defaults(session) |> assign_league(params)
    BackendWeb.Endpoint.subscribe("entity_leagues_#{socket.assigns.league_id}")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Context put={{ user: @user }} >
      <div class="container">
        <FantasyLeague id={{"fantasy_league_#{@league_id}"}} league={{ @league }} />
      </div>
    </Context>
    """
  end

  defp assign_league(socket, %{"league_id" => league_id}), do: socket |> assign_league(league_id)

  defp assign_league(socket, league_id) when is_binary(league_id) do
    socket
    |> assign(league_id: league_id, league: get_league(league_id) || %{})
  end

  defp get_league(league_id), do: Fantasy.get_league(league_id)

  def handle_info(
        %{payload: %{id: payload_id, table: "leagues"}},
        socket = %{assigns: %{league_id: league_id}}
      )
      when league_id == payload_id do
    IO.inspect(payload_id)
    {:noreply, socket |> assign_league(payload_id)}
  end
end
