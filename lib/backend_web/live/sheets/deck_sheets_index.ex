defmodule BackendWeb.DeckSheetsIndexLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Sheets
  alias Backend.Sheets.DeckSheet
  alias Backend.UserManager.User
  alias Components.DeckSheetsModal
  alias Components.DeleteModal

  data(user, :any)
  data(streams, :any)

  def mount(_params, session, socket) do
    if connected?(socket), do: Sheets.subscribe_to_sheets()

    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()
     |> assign(:page_title, "Deck Sheets")
     |> stream_sheets()}
  end

  def render(%{user: %{id: _}} = assigns) do
    ~F"""
        <div>
          <.page_header title="Deck Sheets"/>
          <.filter_container>
            <DeckSheetsModal id="new_modal" user={@user}/>
          </.filter_container>
        </div>
        <.table id="deck_sheets_table">
          <.thead>
            <.trh>
              <.th>Name</.th>
              <.th>Owner</.th>
              <.th>Group</.th>
              <.th>Actions</.th>
            </.trh>
          </.thead>
          <.tbody id="deck_sheets_body" phx-update="stream">
            <.trb :for={{dom_id, sheet} <- @streams.sheets} id={dom_id}>
              <.td>
                <a href={"/deck-sheets/#{sheet.id}"} target="#">{sheet.name}</a>
              </.td>
              <.td>{User.display_name(sheet.owner)}</.td>
              <.td>{group_name(sheet)}</.td>
              <.td>
                <div class="tw-flex tw-gap-1">
                  <DeleteModal :if={Sheets.can_admin?(sheet, @user)} id={"delete_modal_#{sheet.id}"} on_delete={fn -> Backend.Sheets.delete_sheet(sheet, @user) end} success_message="Sheet deleted" error_message="Could not delete sheet"/>
                  <DeckSheetsModal id={"edit_modal_#{sheet.id}"} user={@user} existing={sheet}/>
                </div>
              </.td>
            </.trb>
          </.tbody>
        </.table>
    """
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-3">Please login to access Deck Sheets</div>
      </div>
    """
  end

  defp group_name(%{group: %{name: name}}), do: name
  defp group_name(_), do: nil

  def handle_info(%{event: event, payload: %DeckSheet{}}, socket)
      when event in ["inserted_sheet", "updated_sheet", "deleted_sheet"] do
    {:noreply, stream_sheets(socket)}
  end

  # refetch instead of inserting/deleting since access (groups, roles) can change with an update
  defp stream_sheets(%{assigns: %{user: %{id: _} = user}} = socket),
    do: stream(socket, :sheets, Sheets.viewable_deck_sheets(user), reset: true)

  defp stream_sheets(socket), do: stream(socket, :sheets, [], reset: true)
end
