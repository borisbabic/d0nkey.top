defmodule BackendWeb.BattlefyMatchLive do
  @moduledoc false
  use Surface.LiveView
  import BackendWeb.LiveHelpers

  data(user, :any)
  data(tournament, :map)
  data(match, :map)

  alias Backend.Battlefy
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchTeam
  alias Backend.Hearthstone.Deck
  alias BackendWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)}
  end

  def render(assigns) do
    ~F"""
    <Context  put={user: @user}>
      <div class="container">
        <div class="title is-2">
          <a href={"#{Battlefy.get_match_url(@tournament, @match)}"}>
            {title(@match)}
          </a>
        </div>
        <div class="subtitle is-5">
          {subtitle(@match)}
        </div>
        <table class="table is-fullwidth"> 
          <thead>
            <tr>
              <th>{@match.top |> MatchTeam.get_name() |> player(@tournament)}</th>
              <th>Score</th>
              <th>{@match.bottom |> MatchTeam.get_name() |> player(@tournament)}</th>
              <th>When</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={times <- times(@match)} > 
              <td>{times.top}</td>
              <td></td>
              <td>{times.bottom}</td>
              <td>{times.when || "?"} min ago</td>
            </tr>
            <tr :for={game <- games(@match)} >
              <td>{game.top_class |> Deck.class_name()}</td>
              <td>{game.score}</td>
              <td>{game.bottom_class |> Deck.class_name()}  </td>
              <td>{game.finished || "?"} min ago</td>
            </tr>
          </tbody>
        </table>
      </div>
    </Context>
    """
  end

  def player(nil, _), do: ""

  def player(name, tournament) do
    link = Routes.battlefy_path(BackendWeb.Endpoint, :tournament_player, tournament.id, name)

    ~E"""
    <a href=<%= link %> ><%= name %></a>
    """
  end

  def times(%{top: top, bottom: bottom}) do
    now = NaiveDateTime.utc_now()

    [
      %{
        top: "Check In",
        when: top && top.ready_at,
        bottom: ""
      },
      %{
        top: "Banned",
        when: top && top.banned_at,
        bottom: ""
      },
      %{
        bottom: "Check In",
        when: bottom && bottom.ready_at,
        top: ""
      },
      %{
        bottom: "Banned",
        when: bottom && bottom.banned_at,
        top: ""
      }
    ]
    |> Enum.filter(& &1.when)
    |> Enum.sort_by(& &1.when, fn a, b -> :lt == NaiveDateTime.compare(a, b) end)
    |> Enum.map(&%{&1 | when: min_ago(&1.when, now)})
  end

  def subtitle(%{top: top, bottom: bottom}) do
    if Enum.all?([top, bottom], & &1.banned_at) do
      min_ago =
        if :gt == NaiveDateTime.compare(top.banned_at, bottom.banned_at) do
          top.banned_at
        else
          bottom.banned_at
        end
        |> min_ago(NaiveDateTime.utc_now())

      "Banned #{min_ago} min ago"
    else
      "Banning not done"
    end
  end

  def title(%{top: top, bottom: bottom}) do
    "#{top |> MatchTeam.get_name()} vs #{bottom |> MatchTeam.get_name()}"
  end

  def games(match) do
    now = NaiveDateTime.utc_now()

    match.stats
    |> Enum.sort_by(& &1.game_number, :asc)
    |> Enum.map(fn
      %{
        created_at: created_at,
        stats: %{bottom: %{class: bottom_class, winner: bw}, top: %{class: top_class, winner: tw}}
      } ->
        %{
          top_class: top_class,
          bottom_class: bottom_class,
          finished: min_ago(created_at, now),
          score: "#{score(tw)} - #{score(bw)}"
        }

      %{created_at: created_at} ->
        %{
          top_class: "",
          bottom_class: "",
          finished: min_ago(created_at, now),
          score: ""
        }

      _ ->
        %{
          top_class: "",
          bottom_class: "",
          finished: "?",
          score: ""
        }
    end)
  end

  defp min_ago(nil, _now), do: nil

  defp min_ago(comparison, now) do
    now_stamp = now |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix()

    comp_stamp =
      comparison
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.to_unix()

    ((now_stamp - comp_stamp) / 60)
    |> Float.round()
    |> trunc()
  end

  defp score(true), do: 1
  defp score(_), do: 0

  def handle_params(%{"match_id" => match_id, "tournament_id" => tournament_id}, _uri, socket) do
    tournament = Battlefy.get_tournament(tournament_id)

    match =
      case Integer.parse(match_id) do
        {match_num, ""} ->
          tournament
          |> Backend.Battlefy.get_tournament_matches()
          |> Match.find(match_num)

        _ ->
          Battlefy.get_match!(match_id)
      end

    {:noreply, socket |> assign(match: match, tournament: tournament)}
  end

  # def handle_event("deck_copied", %{"deckcode" => code}, socket) do
  # Tracker.inc_copied(code)
  # {:noreply, socket}
  # end
end
