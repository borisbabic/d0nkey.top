defmodule BackendWeb.DeckSheetsIndexLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Sheets
  alias Backend.UserManager.User
  alias Components.DeckSheetsModal
  alias Components.SurfaceBulma.Table
  alias Components.SurfaceBulma.Table.Column
  alias Components.DeleteModal

  data(user, :any)

  def mount(_params, session, socket),
    do:
      {:ok,
       socket
       |> assign_defaults(session)
       |> put_user_in_context()
       |> assign(:page_title, "Deck Sheets")}

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
          <.tbody>
            <.trb :for={sheet <- sheets(@user)}>
              <.td>
                <a href={"/deck-sheets/#{sheet.id}"} target="#">{sheet.name}</a>
              </.td>
              <.td>{User.display_name(sheet.owner)}</.td>
              <.td>{group_name(sheet)}</.td>
              <.td>
                <div class="tw-flex tw-gap-1">
                  <DeleteModal :if={Sheets.can_admin?(sheet, @user)} id={"delete_modal_#{sheet.id}"} on_delete={fn -> Backend.Sheets.delete_sheet(sheet, @user) end}/>
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

  defp sheets(user) do
    Sheets.viewable_deck_sheets(user)
  end
end
