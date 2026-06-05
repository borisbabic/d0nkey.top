defmodule FunctionComponents.Battlefy do
  @moduledoc false

  use BackendWeb, :component

  alias Backend.Hearthstone.Deck
  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Organization
  alias Backend.Battlefy.MatchTeam
  alias FunctionComponents.Dropdown
  attr :stages, :list, required: true
  attr :title, :string, required: true

  def stage_selection_dropdown(assigns) do
    ~H"""
      <Dropdown.menu title={@title}>
          <%= for %{name: name, selected: selected, link: link} <- @stages do %>
              <Dropdown.item selected={selected}  href={link}>
                  <%=name%>
              </Dropdown.item>
          <% end %>
      </Dropdown.menu>
    """
  end

  attr :tournament, :map, required: true

  def tournament_card(assigns) do
    ~H"""
      <div class="card">
        <header class="card-header">
          <p class="card-header-title">
            <a href={~p"/battlefy/tournament/#{@tournament.id}"} class="card-footer-item"><%= @tournament.name %></a>
          </p>
        </header>
        <div class="card-content">
          <div class="content">
            <a :if={@tournament.organization} href={Organization.create_link(@tournament.organization)}>{Organization.display_name(@tournament.organization)}</a>
            <br>
            <label>Start Time:</label>
            <Components.Helper.datetime datetime={@tournament.start_time}/>
          </div>
        </div>
        <footer class="card-footer">
          <a href={~p"/battlefy/tournament/#{@tournament.id}/participants"} class="card-footer-item">Participants</a>
          <a :if={Tournament.has_bracket(@tournament)} href={~p"/battlefy/tournament/#{@tournament.id}/lineups"} class="card-footer-item">Lineups</a>
          <a :if={Tournament.has_bracket(@tournament)} href={~p"/tournament-lineups/battlefy/#{@tournament.id}/stats"} class="card-footer-item">Winrate</a>
          <a :if={Tournament.has_bracket(@tournament)} href={~p"/tournament-lineups/battlefy/#{@tournament.id}/popularity"} class="card-footer-item">Popularity</a>
          <a :if={Tournament.has_bracket(@tournament)} href={~p"/streaming-now?for_tournament=battlefy|#{@tournament.id}"} class="card-footer-item">Other Streams</a>
        </footer>
      </div>
    """
  end

  attr :tournament_id, :string, required: true
  attr :match, :map, required: true
  attr :top_decks, :list, default: []
  attr :bottom_decks, :list, default: []

  def match_table(assigns) do
    ~H"""
      <table class="table is-fullwidth">
        <thead>
          <tr>
            <th>{@match.top |> MatchTeam.get_name() |> player(@tournament_id)}</th>
            <th>Score</th>
            <th>{@match.bottom |> MatchTeam.get_name() |> player(@tournament_id)}</th>
            <th>When</th>
          </tr>
        </thead>
        <tbody>
          <tr :if={Enum.any?(@top_decks) or Enum.any?(@bottom_decks)}>
            <td>{render_decks(@top_decks)}</td>
            <td></td>
            <td>{render_decks(@bottom_decks)}</td>
            <td></td>
          </tr>
          <tr :for={times <- match_times(@match, @top_decks, @bottom_decks)} >
            <td>{times.top}</td>
            <td>{Map.get(times, :score)}</td>
            <td>{times.bottom}</td>
            <td>{Util.from_now(times.when)}</td>
          </tr>
          <tr :for={game <- games(@match)} >
            <td>{decks(@top_decks, game.top_class) |> render_decks(game.game_identifier <> "_top")}</td>
            <td>{game.score}</td>
            <td>{decks(@bottom_decks, game.bottom_class) |> render_decks(game.game_identifier <> "_bottom")}</td>
            <td>{Util.from_now(game.finished)}</td>
          </tr>
        </tbody>
      </table>
    """
  end

  defp games(match) do
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
          finished: created_at,
          game_identifier: game_identifier(g),
          score: "#{score(tw)} - #{score(bw)}"
        }

      %{created_at: created_at} = g ->
        %{
          top_class: "",
          bottom_class: "",
          finished: created_at,
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

  defp score(true), do: 1
  defp score(_), do: 0

  defp player(nil, _), do: ""

  defp player(name, tournament_id) do
    link = Routes.battlefy_path(BackendWeb.Endpoint, :tournament_player, tournament_id, name)

    assigns = %{link: link, name: name}

    ~H"""
    <a href={@link}><%= @name %></a>
    """
  end

  defp match_times(%{top: top, bottom: bottom}, top_decks, bottom_decks) do
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
  end

  def render_decks(decks, id \\ nil, fallback \\ "")

  def render_decks(decks, nil, fallback) do
    render_decks(decks, Ecto.UUID.generate(), fallback)
  end

  def render_decks(decks, id, fallback) do
    BackendWeb.BattlefyMatchLive.render_decks(decks, id, fallback)
  end

  defp game_identifier(%{game_id: game_id, game_number: game_number}),
    do: "#{game_id}_#{game_number}"

  defp game_identifier(_), do: "Unknown_game_identifier_#{Ecto.UUID.generate()}"

  defp decks(decks, lower_class) when is_binary(lower_class) do
    class = String.upcase(lower_class)

    Enum.filter(decks, fn d ->
      Deck.class(d) == class
    end)
  end

  defp decks(_, _), do: []

  attr :bracket, :map, required: true
  attr :show_championship, :boolean, default: true
  attr :show_consolation, :boolean, default: true
  attr :show_final, :boolean, default: true
  attr :tournament_id, :string, default: nil

  attr :render_decks, :fun, default: nil

  attr :lineups, :map, default: %{}
  slot :lineup, doc: "Lineup view for "

  def bracket(assigns) do
    ~H"""
      <%= if @show_final && @bracket.final do %>
        <.sub_bracket sub_bracket={@bracket.final} tournament_id={@tournament_id} lineups={@lineups} render_decks={@render_decks} strike_through_losers={false} />
      <% end %>
      <br>
      <%= if @show_championship && @bracket.championship do %>
        <.sub_bracket sub_bracket={@bracket.championship} tournament_id={@tournament_id} lineups={@lineups} render_decks={@render_decks} strike_through_losers={@bracket.style == "single"}/>
      <% end %>
      <br>
      <%= if @show_consolation && @bracket.final do %>
        <.sub_bracket sub_bracket={@bracket.consolation} tournament_id={@tournament_id} lineups={@lineups} render_decks={@render_decks} strike_through_losers={true}/>
      <% end %>

    """
  end

  attr :sub_bracket, :map, required: true
  attr :tournament_id, :string, default: nil
  attr :stage_id, :string, default: nil
  attr :lineups, :map, default: %{}

  attr :render_decks, :fun, default: nil
  attr :strike_through_losers, :boolean, default: false

  def sub_bracket(assigns) do
    most_matches = most_matches(assigns.sub_bracket.rounds)

    # Inject total_rounds into assigns so it's safely accessible in HEEx
    assigns = assign(assigns, :most_matches, most_matches)

    ~H"""
      <div class={"tw-grid tw-grid-flow-col tw-grid-cols-#{@sub_bracket.total_rounds} tw-gap-x-12 tw-overflow-x-auto"}>
        <%= for { %{matches: matches}, round_index } <- Enum.with_index(@sub_bracket.rounds) do %>
          <div class={"tw-grid tw-mx-2 tw-grid-rows-#{@most_matches} tw-grid-flow-row tw-items-center"}>
          <%= for {%{top: top, bottom: bottom} = match, match_index} <- Enum.with_index(matches) do %>
            <% 
              even? = rem(match_index, 2) == 0
              line_down? = even? and (match_index + 1) < Enum.count(matches)
              last_round? = round_index == @sub_bracket.total_rounds - 1
              first_round? = round_index == 0
              
              # Calculate the multiplier based on your existing row math
              line_stretch = trunc(@most_matches / Enum.count(matches))
            %>
            
            <div class={"tw-relative tw-rounded-md tw-bg-[#232a2a] tw-text-gray-200 tw-px-4 tw-py-2 tw-row-span-1 tw-row-start-#{2 + trunc(match_index * @most_matches / Enum.count(matches))}"}>
              
              <%= if !last_round? do %>
                <div class="tw-absolute tw-right-[-1.5rem] tw-top-1/2 tw-w-6 tw-h-[2px] tw-bg-gray-600 tw-transform tw--translate-y-1/2"></div>
                
                <%= if line_down? do %>
                  <div 
                    class="tw-absolute tw-right-[-1.5rem] tw-top-1/2 tw-w-[2px] tw-bg-gray-600" 
                    style={"height: calc(#{line_stretch * 100}%);"}
                  ></div>
                <% end %>
              <% end %>

              <%= if !first_round? do %>
                <div class="tw-absolute tw-left-[-2.5rem] tw-top-1/2 tw-w-10 tw-h-[2px] tw-bg-gray-600 tw-transform tw--translate-y-1/2"></div>
              <% end %>

              <div class={if use_modal?(match), do: "tw-cursor-pointer"} phx-click={if use_modal?(match), do: show_modal("match-modal-#{match.id}")}>
                <.player_cell name={MatchTeam.get_name(top)} score={top.score} class={player_cell_class(match.is_complete, top.winner, @strike_through_losers)}tournament_id={@tournament_id} lineups={@lineups} stage_id={@stage_id} match_id={Map.get(match, :id)} render_decks={@render_decks}/>
                <div class="tw-border-t tw-border-gray-700 tw-my-1"></div>
                <.player_cell name={MatchTeam.get_name(bottom)} score={bottom.score} class={player_cell_class(match.is_complete, bottom.winner, @strike_through_losers)} tournament_id={@tournament_id} lineups={@lineups} stage_id={@stage_id} match_id={Map.get(match, :id)} render_decks={@render_decks}/>
              </div>
              <.modal :if={use_modal?(match)} id={"match-modal-#{match.id}"} title={"#{MatchTeam.get_name(top)} vs #{MatchTeam.get_name(bottom)}"}>
                <.match_table match={match} tournament_id={@tournament_id} />
              </.modal>
            </div>
            <%= if last_round? && @sub_bracket.third_place_round do %>
              <%=
              assigns
              |> assign(sub_bracket: %{third_place_round: false, total_rounds: 1, rounds: [@sub_bracket.third_place_round]})
              |> sub_bracket()
              %>
            <% end %>
          <% end %>
          </div>
        <% end %>
      </div>

    """
  end

  defp use_modal?(%{stats: [_ | _]}), do: true
  defp use_modal?(_), do: false

  attr :name, :string, required: true
  attr :winner, :boolean, default: false
  attr :score, :integer, default: 0
  attr :tournament_id, :string, default: nil
  attr :stage_id, :string, default: nil
  attr :match_id, :string, default: nil
  attr :lineups, :map, default: %{}
  attr :render_decks, :fun, default: nil
  attr :class, :string, default: ""

  def player_cell(assigns) do
    lineup = get_lineup(assigns)

    new_assigns =
      if lineup do
        [col_count: 3, decks: lineup.decks]
      else
        [col_count: 2, decks: nil]
      end

    assigns = assigns |> assign(new_assigns)

    ~H"""
      <div class={"tw-grid tw-grid-flow-col tw-grid-cols-#{@col_count} #{@class}"}>
        <%= if @decks do %>
          <%= (@render_decks || &render_decks/1).(@decks) %>
        <% end %>
        <p>
          <%= if @tournament_id && @name do %>
            <.player_link name={@name} tournament_id={@tournament_id} stage_id={@stage_id} />
          <% else %>
            <%= render_player_name(@name, true) %>
          <% end %>
        </p>
        <%= if @tournament_id && @match_id do %>
          <a class="tw-text-right tw-font-mono " onclick="event.stopPropagation()" href={~p"/battlefy/tournament/#{@tournament_id}/match/#{@match_id}"}><%= @score %></a>
        <% else %>
          <p class="tw-text-right tw-font-mono " onclick="event.stopPropagation()" ><%= @score %></p>
        <% end %>
      </div>
    """
  end

  defp player_cell_class(true, true, _strike_through_losers), do: "tw-font-semibold"

  defp player_cell_class(true, false, strike_through_losers) do
    if strike_through_losers do
      "tw-font-extralight tw-line-through"
    else
      "tw-font-extralight"
    end
  end

  defp player_cell_class(_, _, _), do: ""

  defp get_lineup(%{lineups: lineups, name: name}), do: get_lineup(lineups, name)

  defp get_lineup(lineups, name) when is_map(lineups) do
    Map.get(lineups, name)
  end

  defp get_lineup(lineups, name) when is_list(lineups) do
    Enum.find(lineups, &(&1.name == name))
  end

  defp get_lineup(_, _), do: nil

  defp most_matches(rounds) do
    Enum.map(rounds, &Enum.count(&1.matches)) |> Enum.max(fn -> 0 end)
  end

  attr :tournament_id, :string, required: true
  attr :stage_id, :string, default: nil
  attr :name, :string, required: true
  attr :with_country, :boolean, default: true
  attr :stop_propagation, :boolean, default: false

  def player_link(assigns) do
    ~H"""
      <Helper.player_link name={@name} stop_propagation={true} link={~p"/battlefy/tournament/#{@tournament_id}/player/#{@name}?#{if @stage_id, do: %{stage_id: @stage_id}, else: ""}"} />
    """
  end
end
