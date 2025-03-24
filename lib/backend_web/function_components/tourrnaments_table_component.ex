defmodule FunctionComponents.TournamentsTable do
  @moduledoc false
  use Phoenix.Component
  alias Backend.Tournaments.Tournament
  alias Components.Helper
  alias FunctionComponents.EsportsBadges

  attr :tournaments, :list, required: true

  def table(assigns) do
    ~H"""
    <table class="table is-striped is-fullwidth is-narrow">
      <thead>
      <tr>
          <th>Name</th>
          <th>Start Time</th>
          <th>Tags</th>
      </tr>
      </thead>
      <tbody>
        <%= for tournament <- @tournaments do %>
          <tr>
            <td>
              <a class="is-link" href={Tournament.standings_link(tournament)}>
                <%= Tournament.name(tournament) %>
              </a>
            </td>
            <td :if={start_time = Tournament.start_time(tournament)} class={start_time_class(start_time)}>
              <Helper.datetime datetime={start_time} />
            </td>
            <td :if={!Tournament.start_time(tournament)}> </td>
            <td>
              <EsportsBadges.badges badges={Tournament.tags(tournament)} />
            </td>
          </tr>
        <% end %>
      </tbody>

    </table>
    """
  end

  @spec start_time_class(NaiveDateTime.t()) :: boolean
  defp start_time_class(start_time) do
    if already_started?(start_time) do
      "tw-text-gray-400"
    end
  end

  @spec already_started?(NaiveDateTime.t()) :: boolean()
  defp already_started?(start_time) do
    :lt == NaiveDateTime.compare(start_time, NaiveDateTime.utc_now())
  end
end
