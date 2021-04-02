defmodule BackendWeb.FantasyIndexLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Fantasy
  alias Components.FantasyLeaguesTable
  alias Components.FantasyModal
  import BackendWeb.LiveHelpers

  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns = %{user: %{id: _}}) do
    ~H"""
    <Context put={{ user: @user }} >
      <div class="container">
        <div class="title is-2">Fantasy Leagues</div>
        <div class="level">
          <div class="level-left">
            <FantasyModal id="create_modal" title="Create Fantasy League"/> 
            <a class="is-link button" href="/fantasy/leagues/join/e5b76f1c-979c-4da5-b084-7cbef78b14e9">Join the d0nkey.top GM League</a>
          </div>
        </div>
        <FantasyLeaguesTable leagues={{ get_user_leagues(@user)}} />
      </div>
    </Context>
    """
  end

  def render(assigns) do
    ~H"""
    <Context put={{ user: @user }} >
      <div class="container">
        <div class="title is-3">Please login to access Fantasy Leagues!</div>
      </div>
    </Context>
    """
  end

  defp get_user_leagues(user = %Backend.UserManager.User{}) do
    Fantasy.get_user_leagues(user)
  end

  defp get_user_leagues(_), do: []
end
