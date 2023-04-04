defmodule Backend.SheetsTest do
  use Backend.DataCase
  alias Backend.Sheets
  alias Backend.Hearthstone

  describe "deck sheets" do
    alias Backend.Sheets

    test "create valid deck sheet" do
      user = %{id: id} = create_temp_user()
      name = "Test Name"

      assert {:ok, %{name: ^name, owner_id: ^id, group_id: nil}} =
               Sheets.create_deck_sheet(user, name)
    end

    test "change name successfully" do
      %{sheet: sheet, owner: owner} = create_sheet()
      new_name = Ecto.UUID.generate()
      assert {:ok, %{name: ^new_name}} = Sheets.edit_deck_sheet(sheet, %{name: new_name}, owner)
    end

    test "successfully allow anybody to admin" do
      new_name = Ecto.UUID.generate()
      %{sheet: sheet, owner: owner} = create_sheet()
      # can't edit anonymously before changing
      assert {:error, _} = Sheets.edit_deck_sheet(sheet, %{name: new_name}, nil)
      assert {:ok, edited} = Sheets.edit_deck_sheet(sheet, %{public_role: :admin}, owner)

      assert {:ok, %{name: ^new_name}} = Sheets.edit_deck_sheet(edited, %{name: new_name}, nil)
    end
  end

  describe "deck sheet listings" do
    test "error when no permission to view listings" do
      %{sheet: sheet} = create_sheet()
      assert {:error, _} = Sheets.get_listings(sheet, nil)
      other_user = create_temp_user()
      assert {:error, _} = Sheets.get_listings(sheet, other_user)
    end

    test "error creating new listing with no perm" do
      %{sheet: sheet, owner: owner} = create_sheet()

      {:ok, deck} =
        Hearthstone.create_or_get_deck(
          "AAEBAR8EpIgD25EE57kEsJMFDbsF2QmBCuq7Ao7DAqLOA7nQA9vtA4j0A+q5BIPIBL/TBMDtBAA="
        )

      assert {:error, _} = Sheets.create_deck_sheet_listing(sheet, deck, create_temp_user())
    end

    test "create new listing" do
      %{sheet: sheet, owner: owner} = create_sheet()

      {:ok, deck} =
        Hearthstone.create_or_get_deck(
          "AAEBAR8EpIgD25EE57kEsJMFDbsF2QmBCuq7Ao7DAqLOA7nQA9vtA4j0A+q5BIPIBL/TBMDtBAA="
        )

      assert {:ok, listing} = Sheets.create_deck_sheet_listing(sheet, deck, owner)
    end

    test "create new listing with comment" do
      %{sheet: sheet, owner: owner} = create_sheet()

      comment = Ecto.UUID.generate()

      {:ok, deck} =
        Hearthstone.create_or_get_deck(
          "AAEBAR8EpIgD25EE57kEsJMFDbsF2QmBCuq7Ao7DAqLOA7nQA9vtA4j0A+q5BIPIBL/TBMDtBAA="
        )

      assert {:ok, %{comment: ^comment}} =
               Sheets.create_deck_sheet_listing(sheet, deck, owner, %{comment: comment})
    end

    test "Successfully change name, source, and comment" do
      %{listing: listing, owner: owner} = create_sheet_listing()
      new_name = Ecto.UUID.generate()
      new_comment = Ecto.UUID.generate()
      new_source = Ecto.UUID.generate()

      assert {:ok, %{source: ^new_source, name: ^new_name, comment: ^new_comment}} =
               Sheets.edit_deck_sheet_listing(
                 listing,
                 %{name: new_name, comment: new_comment, source: new_source},
                 owner
               )
    end
  end

  defp create_sheet(extra_attrs \\ %{}) do
    user = create_temp_user()
    name = Map.get(extra_attrs, :name, "Test Name")
    {:ok, sheet} = Sheets.create_deck_sheet(user, name, extra_attrs)

    %{
      owner: user,
      sheet: sheet,
      name: name
    }
  end

  defp create_sheet_listing(
         extra_listing_attrs \\ %{},
         extra_sheet_attrs \\ %{},
         deckcode \\ "AAEBAR8EpIgD25EE57kEsJMFDbsF2QmBCuq7Ao7DAqLOA7nQA9vtA4j0A+q5BIPIBL/TBMDtBAA="
       ) do
    {:ok, deck} = Hearthstone.create_or_get_deck(deckcode)
    %{sheet: sheet, name: sheet_name, owner: owner} = create_sheet(extra_sheet_attrs)
    {:ok, listing} = Sheets.create_deck_sheet_listing(sheet, deck, owner, extra_listing_attrs)

    %{
      sheet: sheet,
      sheet_name: sheet_name,
      owner: owner,
      listing: listing
    }
  end
end
