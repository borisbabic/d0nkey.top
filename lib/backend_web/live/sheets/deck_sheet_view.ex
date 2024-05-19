defmodule BackendWeb.DeckSheetViewLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  use Components.ExpandableDecklist
  alias Backend.Sheets
  alias Backend.UserManager.User
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Components.DeckSheetsModal
  alias Components.DeckListingModal
  alias Components.DeckCard
  alias Components.Decklist
  alias Components.SurfaceBulma.Table
  alias Components.SurfaceBulma.Table.Column
  alias Components.LivePatchDropdown
  alias Components.Filter.PlayableCardSelect
  alias Components.Filter.ClassDropdown
  alias Components.DecksExplorer
  alias Components.DeleteModal

  data(sheet, :integer)
  data(sheet_id, :integer)
  data(user, :any)
  data(deck_filters, :any)
  data(view_mode, :string, default: "sheet")

  def mount(params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> assign_sheet(params) |> put_user_in_context()}

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns = %{sheet: %{}}) do
    ~F"""
        {#if Sheets.can_view?(@sheet, @user)}
          <div class="title is-1">{@sheet.name}</div>
          <div class="subtitle is-5">Owner: {User.display_name(@sheet.owner)}</div>
          <div class="level level-left">
            {#if Sheets.can_admin?(@sheet, @user)}
              <DeckSheetsModal button_title="Edit Sheet" id={"edit_modal_#{@sheet.id}"} existing={@sheet} user={@user}/>
            {/if}
            {#if Sheets.can_contribute?(@sheet, @user)}
              <DeckListingModal button_title="Add Deck(s)" id={"create_new_listing"} sheet={@sheet} user={@user}/>
            {/if}

          <LivePatchDropdown
            options={[{"sheet", "Sheet"}, {"decks", "Decks"}]}
            title={"View Mode"}
            param={"view_mode"}
            live_view={__MODULE__} />
          <ClassDropdown id="deck_class_dropdown" param="deck_class" />
            <PlayableCardSelect id={"deck_include_cards"} update_fun={PlayableCardSelect.update_cards_fun(@deck_filters, "deck_include_cards")} selected={@deck_filters["deck_include_cards"] || []} title="Include cards"/>
            <PlayableCardSelect id={"deck_exclude_cards"} update_fun={PlayableCardSelect.update_cards_fun(@deck_filters, "deck_exclude_cards")} selected={@deck_filters["deck_exclude_cards"] || []} title="Exclude cards"/>
          </div>
          <Table :if={@view_mode == "sheet"} id="deck_sheet_listing_table" data={listing <- Sheets.get_listings!(@sheet, @user, @deck_filters)} striped>
            <Column label="Deck"><ExpandableDecklist deck={listing.deck} name={listing.name} id={"expandable_deck_for_listing_#{listing.id}"}/> </Column>
            <Column label="Source">{listing.source}</Column>
            <Column label="Comment">{listing.comment}</Column>
            <Column label="Actions">
              <div class="level level-left">
                <DeleteModal :if={Sheets.can_contribute?(@sheet, @user)} id={"delete_modal_#{listing.id}"} on_delete={fn -> Backend.Sheets.delete_listing(listing, @user) end}/>
                <DeckListingModal :if={Sheets.can_contribute?(@sheet, @user)} id={"edit_listing_#{listing.id}"} user={@user} existing={listing}/>
              </div>
            </Column>
          </Table>
          <div :if={@view_mode == "decks"} class="columns is-multiline is-mobile is-narrow is-centered">
            <div :for={listing <- Sheets.get_listings!(@sheet, @user, @deck_filters)} class="column is-narrow">
              <DeckCard after_deck_class={"columns is-multiline is-mobile"}>
                <Decklist deck={listing.deck} name={listing.name} id={"deck_for_#{listing.id}"} />
                <:after_deck>
                  <DeckListingModal :if={Sheets.can_contribute?(@sheet, @user)} id={"edit_listing_#{listing.id}"} user={@user} existing={listing}/>
                  <DeleteModal :if={Sheets.can_contribute?(@sheet, @user)} id={"delete_modal_#{listing.id}"} on_delete={fn -> Backend.Sheets.delete_listing(listing, @user) end}/>
                  <div class="tag column is-info" :if={listing.source}>{listing.source}</div>
                  <p class="column has-text-centered is-word-wrap" :if={listing.comment && listing.comment != ""}>{listing.comment}</p>
                </:after_deck>
              </DeckCard>
            </div>

          </div>
        {#else}
          <span>Can't view sheet, insufficient permissions</span>
        {/if}
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

  def handle_params(params, _uri, socket) do
    filters =
      Map.take(params, ["deck_include_cards", "deck_exclude_cards", "deck_class"])
      |> DecksExplorer.parse_int(["deck_include_cards", "deck_exclude_cards"])

    view_mode = Map.get(params, "view_mode", "sheet")

    socket =
      assign(socket, :deck_filters, filters) |> assign(:view_mode, view_mode) |> update_context()

    {:noreply, socket}
  end

  defp update_context(%{assigns: assigns} = socket) do
    LivePatchDropdown.update_context(
      socket,
      __MODULE__,
      url_params(assigns),
      path_params(assigns)
    )
  end

  def handle_info({:update_params, params}, socket = %{assigns: assigns}) do
    {:noreply,
     push_patch(socket, to: Routes.live_path(socket, __MODULE__, path_params(assigns), params))}
  end

  defp path_params(%{sheet: %{id: id}}), do: id

  defp url_params(%{deck_filters: df, view_mode: vm}), do: Map.put(df, "view_mode", vm)
end
