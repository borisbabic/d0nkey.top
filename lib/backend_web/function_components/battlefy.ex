defmodule FunctionComponents.Battlefy do
  @moduledoc false

  use BackendWeb, :component

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

  def render_decks(decks) do
    BackendWeb.BattlefyMatchLive.render_decks(decks, Ecto.UUID.generate())
  end

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

              <.player_cell name={MatchTeam.get_name(top)} score={top.score} winner={top.winner} strike_through_losers={match.is_complete && @strike_through_losers} tournament_id={@tournament_id} lineups={@lineups} stage_id={@stage_id} match_id={Map.get(match, :id)} render_decks={@render_decks}/>
              <div class="tw-border-t tw-border-gray-700 tw-my-1"></div>
              <.player_cell name={MatchTeam.get_name(bottom)} score={bottom.score} winner={bottom.winner} strike_through_losers={match.is_complete && @strike_through_losers}  tournament_id={@tournament_id} lineups={@lineups} stage_id={@stage_id} match_id={Map.get(match, :id)} render_decks={@render_decks}/>
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

  attr :name, :string, required: true
  attr :winner, :boolean, default: false
  attr :score, :integer, default: 0
  attr :tournament_id, :string, default: nil
  attr :stage_id, :string, default: nil
  attr :match_id, :string, default: nil
  attr :lineups, :map, default: %{}
  attr :strike_through_losers, :boolean, required: true

  attr :render_decks, :fun, default: nil

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
      <div class={"tw-grid tw-grid-flow-col tw-grid-cols-#{@col_count} #{if @winner, do: "tw-font-bold"} #{if @strike_through_losers and !@winner, do: "tw-line-through" }"}>
        <%= if @decks do %>
          <%= (@render_decks || &render_decks/1).(@decks) %>
        <% end %>
        <%= if @tournament_id && @name do %>
          <p class=""><%= render_player_link(@name, ~p"/battlefy/tournament/#{@tournament_id}/player/#{@name}?#{if @stage_id, do: %{stage_id: @stage_id}, else: ""}", true) %></p>
        <% else %>
          <p class=""><%= render_player_name(@name, true) %></p>
        <% end %>
        <%= if @tournament_id && @match_id do %>
          <a class="tw-text-right tw-font-mono " href={~p"/battlefy/tournament/#{@tournament_id}/match/#{@match_id}"}><%= @score %></a>
        <% else %>
          <p class="tw-text-right tw-font-mono "><%= @score %></p>
        <% end %>
      </div>
    """
  end

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
end
