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
            <a :if={{ show_mt?(:Dalaran) }} class="is-link button" href="/fantasy/leagues/join/adad6039-e4b9-493e-8e5a-fb7e0254f8a9">Join the d0nkey.top Dalaran League</a>
            <a :for={{ {tour, link} <- Dreamhack.current_fantasy() }} class="is-link button" href="{{ link }}">Join DH {{ tour }}</a>
          </div>
        </div>
        <FantasyLeaguesTable leagues={{ get_user_leagues(@user)}} />
      </div>
    </Context>
    """
  end

  def show_dreamhack?() do
    now = NaiveDateTime.utc_now()
  end

  def show_mt?(mt) do
    now = NaiveDateTime.utc_now()

    mt_start =
      mt
      |> Backend.MastersTour.TourStop.get_start_time()

    :lt == NaiveDateTime.compare(now, mt_start)
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
