defmodule Components.RosterModal do
  @moduledoc false
  use Surface.LiveComponent
  alias Backend.Fantasy.LeagueTeam
  alias Backend.Fantasy.League
  alias BackendWeb.Router.Helpers, as: Routes

  prop(show_modal, :boolean, default: false)
  prop(league_team, :map, required: true)
  prop(include_points, :boolean, default: true)

  prop(round, :number, default: nil)

  prop(button_title, :string, default: "View Roster")
  prop(user, :map, from_context: :user)

  def render(assigns) do
    ~F"""
    <div>
      <button class="button" type="button" :on-click="show_modal">{@button_title}</button>
      <div class="modal is-active" :if={@show_modal}>
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{@league_team |> LeagueTeam.display_name()}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body">
              <div class="content">
                <ul :for={{pick_name, points} <- picks_with_points(@league_team, @include_points, round(@league_team, @round))}>
                  <li><span :if={@include_points}>{points} - </span>{show_pick_name(@league_team, @user, pick_name, round(@league_team, @round))}</li>
                </ul>
                <a target="_blank" :if={standings_link = standings_link(@league_team)} class="button is-link " href={"#{standings_link}"}>View in standings</a>
              </div>
            </section>
            <div class="modal-card-foot" :if={show_round_footer?(@league_team)}>
              <button type="button" class="button" :on-click="dec_round" >
                <HeroIcons.chevron_left />
              </button>
              <button type="button" class="button" :on-click="inc_round">
                <HeroIcons.chevron_round />
              </button>
              <p>Round {round(@league_team, @round)}</p>
            </div>
          </div>
        </div>
    </div>
    """
  end

  def round(lt, round), do: League.round(lt.league, round)

  defp show_round_footer?(%{league: %{current_round: current_round}}) when current_round > 1,
    do: true

  defp show_round_footer?(_), do: true

  def standings_link(%{
        picks: picks = [_ | _],
        league: %{competition_type: "masters_tour", competition: ts}
      }) do
    ts
    |> Backend.MastersTour.TourStop.get()
    |> case do
      %{battlefy_id: battlefy_id} when not is_nil(battlefy_id) ->
        params =
          picks
          |> Enum.reduce(%{"highlight_fantasy" => "no", "player" => %{}}, fn %{pick: p}, carry ->
            carry |> put_in(["player", p |> Backend.Battlenet.Battletag.shorten()], true)
          end)

        Routes.battlefy_path(BackendWeb.Endpoint, :tournament, battlefy_id, params)

      _ ->
        nil
    end
  end

  def standings_link(_), do: nil

  defp show_pick_name(
         lt = %{league: league = %{real_time_draft: false, draft_deadline: dd}},
         user,
         name,
         round
       )
       when not is_nil(dd) do
    if LeagueTeam.can_manage?(lt, user) || League.draft_deadline_passed?(league) ||
         round < league.current_round do
      name
    else
      "?????"
    end
  end

  defp show_pick_name(_, _, name, _), do: name

  def picks_with_points(league_team, true, round) do
    results =
      Backend.FantasyCompetitionFetcher.fetch_results(league_team.league, round)
      |> Map.new(&League.normalize_pick(&1, league_team.league))

    league_team
    |> LeagueTeam.round_picks(round)
    |> Enum.map(fn %{pick: pick} ->
      {pick, results |> Map.get(pick |> League.normalize_pick(league_team.league)) || 0}
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

  def handle_event("inc_round", _, socket = %{assigns: %{round: r, league_team: lt}}),
    do: {:noreply, socket |> assign(round: round(lt, r) + 1)}

  def handle_event("dec_round", _, socket = %{assigns: %{round: r, league_team: lt}}),
    do: {:noreply, socket |> assign(round: round(lt, r) - 1)}

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false)}
  end
end
