defmodule BackendWeb.LineupHistoryLive do
  use BackendWeb, :surface_live_view
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Components.ExpandableLineup

  data(name, :string)
  data(source, :string)
  data(user, :any)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div>
        <.page_header title={@name} title_link={Routes.player_path(BackendWeb.Endpoint, :player_profile, @name)} />
        <FunctionComponents.Ads.below_title/>
        <.table id="lineup_history_table" :if={lineups = Backend.Hearthstone.lineup_history(@source, @name)}>
          <.thead>
            <.trh>
              <.th>Submitted</.th>
              <.th>Decks</.th>
            </.trh>
          </.thead>
          <.tbody>
            <.trb :for={l <- lineups}>
              <.td>{l.tournament_id}</.td>
              <.td><ExpandableLineup id={"#{l.tournament_id}#{l.name}"} lineup={l}/></.td>
            </.trb>
          </.tbody>
        </.table>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    name = params["name"]
    source = params["source"]
    {:noreply, socket |> assign(name: name, source: source)}
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
