defmodule FunctionComponents.Battlefy do
  @moduledoc false

  use BackendWeb, :component

  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Organization
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
          <a :if={Tournament.has_bracket(@tournament)} href={~p"/battlefy/tournament/#{@tournament.id}/stats"} class="card-footer-item">Winrate</a>
          <a :if={Tournament.has_bracket(@tournament)} href={~p"/battlefy/tournament/#{@tournament.id}/popularity"} class="card-footer-item">Popularity</a>
          <a :if={Tournament.has_bracket(@tournament)} href={~p"/streaming-now?for_tournament=battlefy|#{@tournament.id}"} class="card-footer-item">Other Streams</a>
        </footer>
      </div>
    """
  end
end
