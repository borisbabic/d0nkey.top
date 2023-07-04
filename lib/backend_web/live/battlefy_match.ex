defmodule BackendWeb.BattlefyMatchLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  data(user, :any)
  data(tournament, :map)
  data(match, :map)
  data(top_decks, :list)
  data(bottom_decks, :list)

  alias Backend.Battlefy
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchTeam
  alias Backend.Hearthstone.Deck
  alias Components.CompactLineup
  use Components.ExpandableDecklist

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">
          <a href={"#{Battlefy.get_match_url(@tournament, @match)}"}>
            {title(@match)}
          </a>
        </div>
        <div class="subtitle is-5">
          {subtitle(@match)}
        </div>
        <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div><br>
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
            <tr :if={Enum.any?(@top_decks) or Enum.any?(@bottom_decks)}>
              <td><CompactLineup extra_decks={@top_decks} id="top_lineup"/></td>
              <td></td>
              <td><CompactLineup extra_decks={@bottom_decks} id="bottom_lineup"/></td>
              <td></td>
            </tr>
            <tr :for={times <- times(@match, @top_decks, @bottom_decks)} >
              <td>{times.top}</td>
              <td>{Map.get(times, :score)}</td>
              <td>{times.bottom}</td>
              <td>{times.when || "?"} min ago</td>
            </tr>
            <tr :for={game <- games(@match)} >
              <td>{decks(@top_decks, game.top_class) |> render_decks(game.game_identifier <> "_top")}</td>
              <td>{game.score}</td>
              <td>{decks(@bottom_decks, game.bottom_class) |> render_decks(game.game_identifier <> "_bottom")}</td>
              <td>{game.finished || "?"} min ago</td>
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  defp game_identifier(%{game_id: game_id, game_number: game_number}),
    do: "#{game_id}_#{game_number}"

  defp game_identifier(_), do: "Unknown_game_identifier_#{Ecto.UUID.generate()}"

  def render_decks(decks, id, fallback \\ "")

  def render_decks([deck], id, _fallback) do
    assigns = %{deck: deck, id: id}

    ~F"""
    <ExpandableDecklist id={@id} deck={@deck}/>
    """
  end

  def render_decks([], _id, fallback), do: fallback

  def render_decks(decks, id, _fallback) do
    assigns = %{decks: decks, id: id}

    ~F"""
    <CompactLineup id={@id} extra_decks={@decks}/>
    """
  end

  def decks(decks, lower_class) when is_binary(lower_class) do
    class = String.upcase(lower_class)

    Enum.filter(decks, fn d ->
      Deck.class(d) == class
    end)
  end

  def decks(_, _), do: []

  def player(nil, _), do: ""

  def player(name, tournament) do
    link = Routes.battlefy_path(BackendWeb.Endpoint, :tournament_player, tournament.id, name)

    ~E"""
    <a href=<%= link %> ><%= name %></a>
    """
  end

  def times(%{top: top, bottom: bottom}, top_decks, bottom_decks) do
    now = NaiveDateTime.utc_now()

    [
      %{
        top: "Check In",
        when: top && top.ready_at,
        bottom: ""
      },
      %{
        top: top && decks(top_decks, top.banned_class) |> render_decks("banned_top", "???"),
        when: top && top.banned_at,
        score: "Banned",
        bottom: ""
      },
      %{
        bottom: "Check In",
        when: bottom && bottom.ready_at,
        top: ""
      },
      %{
        bottom:
          bottom &&
            decks(bottom_decks, bottom.banned_class) |> render_decks("banned_bottom", "???"),
        when: bottom && bottom.banned_at,
        score: "Banned",
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
      } = g ->
        %{
          top_class: top_class,
          bottom_class: bottom_class,
          finished: min_ago(created_at, now),
          game_identifier: game_identifier(g),
          score: "#{score(tw)} - #{score(bw)}"
        }

      %{created_at: created_at} = g ->
        %{
          top_class: "",
          bottom_class: "",
          finished: min_ago(created_at, now),
          identifier: game_identifier(g),
          score: ""
        }

      g ->
        %{
          top_class: "",
          bottom_class: "",
          finished: "?",
          identifier: game_identifier(g),
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
          |> Battlefy.get_tournament_matches()
          |> Match.find(match_num)

        _ ->
          Battlefy.get_match!(match_id)
      end

    {top_decks, bottom_decks} = get_decks(tournament, match)

    {:noreply,
     socket
     |> assign(
       match: match,
       tournament: tournament,
       top_decks: top_decks,
       bottom_decks: bottom_decks
     )}
  end

  defp get_decks(%{id: tournament_id}, %{id: match_id}) do
    case Battlefy.get_match_deckstrings(tournament_id, match_id) do
      %{top: top, bottom: bottom} -> {decks(top), decks(bottom)}
      _ -> {[], []}
    end
  end

  defp decks(strings) do
    for s <- strings, {:ok, deck} = Deck.decode(s), do: deck
  end
end
