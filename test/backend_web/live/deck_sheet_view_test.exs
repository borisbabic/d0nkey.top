defmodule BackendWeb.DeckSheetViewLiveTest do
  use BackendWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Backend.Sheets
  alias Components.DeckListingModal

  test "renders not found", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/deck-sheets/1")
    assert html =~ "not found"
  end

  test "renders insufficient permissions", %{conn: conn} do
    %{sheet: %{id: id}} = create_temp_user() |> create_sheet()
    {:ok, _view, html} = live(conn, "/deck-sheets/#{id}")
    assert html =~ "nsufficient"
  end

  @tag :authenticated
  test "renders when logged in", %{conn: conn, user: user} do
    %{sheet: %{name: name, id: id}} = create_sheet(user)
    {:ok, _view, html} = live(conn, "/deck-sheets/#{id}")
    assert html =~ name
  end

  @tag :authenticated
  test "includes listing", %{conn: conn, user: user} do
    %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
    {:ok, _view, html} = live(conn, "/deck-sheets/#{id}")
    assert html =~ sheet_name
    assert html =~ listing_name
  end

  @tag :authenticated
  test "can edit listing comment", %{conn: conn, user: user} do
    %{sheet: %{name: sheet_name, id: id}, listing: listing = %{name: listing_name}} =
      create_listing(user)

    new_comment = Ecto.UUID.generate()
    {:ok, view, html} = live(conn, "/deck-sheets/#{id}")
    assert html =~ sheet_name
    assert html =~ listing_name
    refute html =~ new_comment
    refute html =~ "Save"

    click_result =
      view
      |> element("button", ~r/Edit$/)
      |> render_click()

    assert click_result =~ "Save"

    view
    |> form("##{DeckListingModal.form_id(listing, nil)}", %{listing: %{comment: new_comment}})
    |> render_submit()

    {:ok, _view, new_html} = live(conn, "/deck-sheets/#{id}")

    assert new_html =~ new_comment
  end

  @tag :authenticated
  test "class filter includes listing", %{conn: conn, user: user} do
    %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
    {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?deck_class=HUNTER")
    assert html =~ sheet_name
    assert html =~ listing_name
  end

  @tag :authenticated
  test "class filter excludes listing", %{conn: conn, user: user} do
    %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
    {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?deck_class=DEMONHUNTER")
    assert html =~ sheet_name
    refute html =~ listing_name
  end

  # @tag :authenticated
  # test "clicking class filter gets the hunter deck included", %{conn: conn, user: user} do
  #   %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
  #   {:ok, view, html} = live(conn, "/deck-sheets/#{id}?deck_class=DEMONHUNTER")
  #   assert html =~ sheet_name
  #   refute html =~ listing_name

  #   click_result = view
  #   |> element("button", ~r/Hunter$/)
  #   |> render_click()

  #   assert html =~ listing_name
  # end
  # @tag :authenticated
  # test "include card filter includes listing", %{conn: conn, user: user} do
  #   %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
  #   {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?deck_include_cards[]=50212")
  #   assert html =~ sheet_name
  #   assert html =~ listing_name
  # end

  # @tag :authenticated
  # test "include card filter excludes listing", %{conn: conn, user: user} do
  #   %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
  #   {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?deck_include_cards[]=0")
  #   assert html =~ sheet_name
  #   refute html =~ listing_name
  # end

  # @tag :authenticated
  # test "exclude card filter excludes listing", %{conn: conn, user: user} do
  #   %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
  #   {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?deck_exclude_cards[]=50212")
  #   assert html =~ sheet_name
  #   refute html =~ listing_name
  # end

  # @tag :authenticated
  # test "exclude card filter include listing", %{conn: conn, user: user} do
  #   %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
  #   {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?deck_exclude_cards[]=0")
  #   assert html =~ sheet_name
  #   assert html =~ listing_name
  # end

  # @tag :authenticated
  # test "clicking flame lance excludes then includes listing ", %{conn: conn, user: user} do
  #   %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
  #   {:ok, view, html} = live(conn, "/deck-sheets/#{id}")
  #   assert html =~ sheet_name
  #   assert html =~ listing_name

  #   first_click =
  #     view
  #     |> element("button", "Flame Lance")
  #     |> render_click()

  #   refute first_click =~ listing_name

  #   second_click =
  #     view
  #     |> element("button", "Flame Lance")
  #     |> render_click()

  #   assert second_click =~ listing_name

  # end

  @tag :authenticated
  test "view mode sheet doesn't include card name", %{conn: conn, user: user} do
    %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
    {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?view_mode=sheet")
    assert html =~ sheet_name
    assert html =~ listing_name
    refute html =~ "Hydralodon"
  end

  @tag :authenticated
  test "view mode decks doesn't include card name", %{conn: conn, user: user} do
    %{sheet: %{name: sheet_name, id: id}, listing: %{name: listing_name}} = create_listing(user)
    {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?view_mode=decks")
    assert html =~ sheet_name
    assert html =~ listing_name
    assert html =~ "Hydralodon"
  end

  @tag :authenticated
  test "view mode sheet works with duplicated deck", %{conn: conn, user: user} do
    %{sheet: sheet = %{name: sheet_name, id: id}, listing: %{name: listing_name, deck: deck}} =
      create_listing(user)

    %{listing: %{name: other_listing_name}} = create_listing(user, sheet, %{deck: deck})
    {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?view_mode=sheet")
    assert html =~ sheet_name
    assert html =~ listing_name
    assert html =~ other_listing_name
  end

  @tag :authenticated
  test "view mode decks works with duplicated deck", %{conn: conn, user: user} do
    %{sheet: sheet = %{name: sheet_name, id: id}, listing: %{name: listing_name, deck: deck}} =
      create_listing(user)

    %{listing: %{name: other_listing_name}} = create_listing(user, sheet, %{deck: deck})
    {:ok, _view, html} = live(conn, "/deck-sheets/#{id}?view_mode=decks")
    assert html =~ sheet_name
    assert html =~ listing_name
    assert html =~ other_listing_name
  end

  #### HELPERS
  defp create_listing(user, sheet \\ nil, extra_attrs \\ %{}) do
    sheet = sheet || Map.fetch!(create_sheet(user), :sheet)
    {deck, base_attrs} = extract_deck(extra_attrs)
    attrs = Map.put_new(base_attrs, :name, Ecto.UUID.generate())

    with {:ok, listing} <- Sheets.create_deck_sheet_listing(sheet, deck, user, attrs) do
      %{listing: listing, sheet: sheet}
    end
  end

  defp extract_deck(extra = %{deck: %{id: _}}), do: Map.pop(extra, :deck)

  defp extract_deck(extra = %{deckcode: code}) do
    with {:ok, deck} <- Backend.Hearthstone.create_or_get_deck(code) do
      {deck, Map.drop(extra, :deckcode)}
    end
  end

  defp extract_deck(extra) do
    with {:ok, deck} <-
           Backend.Hearthstone.create_or_get_deck(
             "AAEBAR8EpIgD25EE57kEsJMFDbsF2QmBCuq7Ao7DAqLOA7nQA9vtA4j0A+q5BIPIBL/TBMDtBAA="
           ) do
      {deck, extra}
    end
  end

  defp create_sheet(user, extra_attrs \\ %{}) do
    {name, attrs} = Map.pop_lazy(extra_attrs, :name, fn -> Ecto.UUID.generate() end)

    with {:ok, sheet} <- Sheets.create_deck_sheet(user, name, attrs) do
      %{sheet: sheet}
    end
  end
end
