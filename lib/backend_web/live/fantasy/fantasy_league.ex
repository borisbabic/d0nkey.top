defmodule BackendWeb.FantasyLeagueLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Fantasy
  alias Components.FantasyLeague
  import BackendWeb.LiveHelpers

  data(user, :any)
  data(league_id, :string)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    ~H"""
    <Context put={{ user: @user }} >
      <div class="container">
        <FantasyLeague league={{ get_league(@league_id) }} />
      </div>
    </Context>
    """
  end

  defp get_league(league_id), do: Fantasy.get_league!(league_id)

  def handle_params(%{"league_id" => league_id}, _session, socket) do
    {:noreply, socket |> assign(league_id: league_id)}
  end
end
