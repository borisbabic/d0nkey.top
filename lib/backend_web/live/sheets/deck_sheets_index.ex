defmodule BackendWeb.DeckSheetsIndexLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Sheets
  alias Backend.UserManager.User
  alias Components.DeckSheetsModal
  alias Components.SurfaceBulma.Table
  alias Components.SurfaceBulma.Table.Column

  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns = %{user: %{id: _}}) do
    ~F"""
      <Context put={user: @user} >
        <div>
          <div class="title is-1">Deck Sheets</div>
          <DeckSheetsModal id="new_modal" user={@user}/>
        </div>
        <Table id="deck_sheets_table" data={sheet <- sheets(@user)} striped>
          <Column label="Name"><a href={"/deck-sheets/#{sheet.id}"} target="#">{sheet.name}</a></Column>
          <Column label="Owner">{User.display_name(sheet.owner)}</Column>
          <Column label="Group">{group_name(sheet)}</Column>
          <Column label="Actions">
            <DeckSheetsModal id={"edit_modal_#{sheet.id}"} user={@user} existing={sheet}/>
          </Column>
        </Table>
      </Context>
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
