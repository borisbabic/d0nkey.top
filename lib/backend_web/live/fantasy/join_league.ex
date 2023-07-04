defmodule BackendWeb.JoinLeagueLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Fantasy
  alias Backend.Fantasy.League
  alias Backend.UserManager.User
  alias Components.JoinLeague

  data(league, :map)
  data(user, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns = %{user: %{id: _}}) do
    ~F"""
      <div>
        <div :if={@league} >
          <div class="title is-2"> Join {@league.name}</div>
          <div class="subtitle is-5 tag"> League owner: {@league.owner |> User.display_name()}</div>
          <div class="subtitle is-5 tag"> Members: {Fantasy.league_members(@league) |> Enum.count()} / {@league.max_teams} </div>
          <div class="subtitle is-5 tag"> Point System: {League.scoring_display(@league)} </div>
          <div class="subtitle is-5 tag"> Roster Size: {@league.roster_size} </div>
          <div :if={@league.draft_deadline} class="subtitle is-5 tag"> Draft Deadline: {render_datetime(@league.draft_deadline )} </div>
            <br>
          <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div><br>
          <a class="link" href={"/fantasy/leagues/#{@league.id}"}>View League</a>
          <div :if={true == already_member?(@league, @user)}>
            You're already a member!
          </div>
          <div :if={false == already_member?(@league, @user)}>
            <JoinLeague id={"join_league_@user.id_"} user={@user} league={@league} />
          </div>
        </div>
        <div :if = {!@league}>
          <div class="title is-2">League Not Found. Maybe the join link/code changed?</div>
        </div>
      </div>
    """
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-3">Please login to join Fantasy Leagues!</div>
      </div>
    """
  end

  def handle_params(%{"join_code" => join_code}, _session, socket) do
    league = Fantasy.get_league_by_code(join_code)
    {:noreply, socket |> assign(league: league)}
  end

  defp already_member?(league, user), do: !!Fantasy.get_user_league(league, user)
end
