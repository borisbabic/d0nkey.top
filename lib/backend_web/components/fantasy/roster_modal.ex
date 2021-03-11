defmodule Components.RosterModal do
  use Surface.LiveComponent
  alias Backend.Fantasy.LeagueTeam
  alias Backend.Fantasy.League

  prop(show_modal, :boolean, default: false)
  prop(league_team, :map, required: true)
  prop(include_points, :boolean, default: true)

  prop(button_title, :string, default: "View Roster")

  def render(assigns) do
    ~H"""
    <Context get={{ user: user }}>
    <div>
      <button class="button" type="button" :on-click="show_modal">{{ @button_title }}</button>
      <div class="modal is-active" :if={{ @show_modal }}>
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{{ @league_team |> LeagueTeam.display_name() }}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body content">
              <ul :for={{ {pick_name, points} <- picks_with_points(@league_team, @include_points) }}>
                <li><span :if={{ @include_points }}>{{ points }} - </span>{{ show_pick_name(@league_team, user, pick_name) }}</li>
              </ul>
            </section>
          </div>
        </div>
    </div>
    </Context>
    """
  end

  defp show_pick_name(
         lt = %{league: league = %{real_time_draft: false, draft_deadline: dd}},
         user,
         name
       )
       when not is_nil(dd) do
    if LeagueTeam.can_manage?(lt, user) || League.draft_deadline_passed?(league) do
      name
    else
      "?????"
    end
  end

  defp show_pick_name(_, _, name), do: name

  def picks_with_points(league_team, true) do
    results = Backend.FantasyCompetitionFetcher.fetch_results(league_team.league)

    league_team.picks
    |> Enum.map(fn %{pick: pick} ->
      {pick, results |> Map.get(pick) || 0}
    end)
    |> Enum.sort_by(&(&1 |> elem(0)), :desc)
    |> Enum.sort_by(&(&1 |> elem(1)), :desc)
  end

  def picks_with_points(league_team, _) do
    league_team.picks
    |> Enum.map(fn %{pick: pick} ->
      {pick, 0}
    end)
    |> Enum.sort_by(&(&1 |> elem(0)), :desc)
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false)}
  end
end
