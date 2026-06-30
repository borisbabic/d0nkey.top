defmodule FunctionComponents.TournamentsTable do
  @moduledoc false
  use BackendWeb, :component
  alias Backend.Tournaments.Tournament
  alias Components.Helper
  alias FunctionComponents.EsportsBadges

  attr :tournaments, :list, required: true
  attr :user_tournaments, :list, default: []

  def tournaments_table(assigns) do
    ~H"""
    <.table id="tournaments_table_table">
      <.thead>
      <.trh>
          <.th>Name</.th>
          <.th>Start Time</.th>
          <.th>Tags</.th>
      </.trh>
      </.thead>
      <.tbody>
        <.trb :for={tournament <- @tournaments}>
          <.td>
            <a class="is-link" href={Tournament.standings_link(tournament)}>
              <%= Tournament.name(tournament) %>
            </a>
          </.td>
          <.td :if={start_time = Tournament.start_time(tournament)} class={start_time_class(start_time)}>
            <Helper.datetime datetime={start_time} />
          </.td>
          <.td :if={!Tournament.start_time(tournament)}> </.td>
          <.td>
            <EsportsBadges.badges badges={tags(tournament, @user_tournaments)} />
          </.td>
        </.trb>
      </.tbody>

    </.table>
    """
  end

  defp tags(tournament, user_tournaments) do
    base_tags = Tournament.tags(tournament)

    if Enum.any?(user_tournaments, &(&1.id == tournament.id)) do
      [:joined | base_tags]
    else
      base_tags
    end
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
