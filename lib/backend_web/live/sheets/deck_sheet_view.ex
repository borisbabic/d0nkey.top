defmodule BackendWeb.DeckSheetViewLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Sheets
  alias Backend.UserManager.User
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Components.DeckSheetsModal
  alias Components.DeckListingModal
  alias Components.ExpandableDecklist
  alias SurfaceBulma.Table
  alias SurfaceBulma.Table.Column

  data(sheet, :integer)
  data(sheet_id, :integer)
  data(user, :any)

  def mount(params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> assign_sheet(params)}

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns = %{sheet: %{}}) do
    ~F"""
      <Context put={user: @user}>
        {#if Sheets.can_view?(@sheet, @user)}
          <div class="title is-1">{@sheet.name}</div>
          <div class="subtitle is-5">Owner: {User.display_name(@sheet.owner)}</div>
          <div class="level level-left">
            {#if Sheets.can_admin?(@sheet, @user)}
              <DeckSheetsModal button_title="Edit Sheet" id={"edit_modal_#{@sheet.id}"} existing={@sheet} user={@user}/>
            {/if}
            {#if Sheets.can_contribute?(@sheet, @user)}
              <DeckListingModal button_title="Add Deck" id={"create_new_listing"} sheet={@sheet} user={@user}/>
            {/if}
          </div>
          <Table id="deck_sheet_listing_table" data={listing <- Sheets.get_listings!(@sheet, @user)} striped>
            <Column label="Deck"><ExpandableDecklist deck={listing.deck} name={listing.name} id={"expandable_deck_for_listing_#{listing.id}"}/> </Column>
            <Column label="Source">{listing.source}</Column>
            <Column label="Comment">{listing.comment}</Column>
            <Column label="Actions">
              <DeckListingModal :if={Sheets.can_contribute?(@sheet, @user)} id={"edit_listing_#{listing.id}"} user={@user} existing={listing}/>
            </Column>
          </Table>
        {#else}
          <span>Can't view sheet, insufficient permissions</span>
        {/if}
      </Context>
    """
  end

  def render(assigns) do
    ~F"""
      <div>Deck Sheet not found</div>
    """
  end

  def assign_sheet(socket, %{"sheet_id" => id}) do
    sheet = Sheets.get_sheet(id)

    assign(socket, :sheet, sheet)
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("deck_expanded", %{"deckcode" => code}, socket) do
    Tracker.inc_expanded(code)
    {:noreply, socket}
  end

  def handle_event("toggle_cards", params, socket) do
    Components.ExpandableDecklist.toggle_cards(params)

    {
      :noreply,
      socket
    }
  end
end
