defmodule BackendWeb.FantasyIndexLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Fantasy
  alias Components.FantasyLeaguesTable
  alias Components.FantasyModal

  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns = %{user: %{id: _}}) do
    ~F"""
    <Context put={user: @user} >
      <div>
        <div class="title is-2">Fantasy Leagues</div>
        <div id="nitropay-below-title-leaderboard"></div><br>
        <div class="level">
          <div class="level-left">
            <FantasyModal id="create_modal" title="Create Fantasy League"/>
            <a class="is-link button" href="/fantasy/leagues/join/7fa963f1-9d15-499b-9e62-03cba011980d">2022 GM Fantasy</a>
            <a :if={show_mt?(:"Masters Tour One")} class="is-link button" href="/fantasy/leagues/join/b633b985-df60-4eca-a123-d4574c9ac51b">Onyxia's Lair (MT One)</a>
            <a :if={show_mt?(:Undercity)} class="is-link button" href="/fantasy/leagues/join/fc8870ed-8e70-4260-822a-e52a3ca69562">Play Undercity Fantasy</a>
            <a :for={{tour, link} <- Dreamhack.current_fantasy()} class="is-link button" href={"#{link}"}>Join DH {tour}</a>
          </div>
        </div>
        <FantasyLeaguesTable leagues={get_user_leagues(@user)} />
      </div>
    </Context>
    """
  end

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div>
        <div class="title is-3">Please login to access Fantasy Leagues!</div>
      </div>
    </Context>
    """
  end

  def show_mt?(mt) do
    now = NaiveDateTime.utc_now()

    mt_start =
      mt
      |> Backend.MastersTour.TourStop.get_start_time()

    :lt == NaiveDateTime.compare(now, mt_start)
  end

  defp get_user_leagues(user = %Backend.UserManager.User{}) do
    Fantasy.get_user_leagues(user)
  end

  defp get_user_leagues(_), do: []
end
