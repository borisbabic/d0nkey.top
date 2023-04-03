defmodule Backend.Sheets do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Backend.Sheets.DeckSheet
  alias Backend.Sheets.DeckSheetListing
  alias Backend.UserManager
  alias Backend.UserManager.Group
  alias Backend.UserManager.User
  alias Backend.Repo

  @spec create_deck_sheet(User.t(), String.t(), Group.t()) ::
          {:ok, DeckSheet.t()} | {:error, any()}
  def create_deck_sheet(owner, name, group \\ nil) do
    attrs = %{owner: owner, name: name, group: group}

    DeckSheet.changeset(%DeckSheet{}, attrs)
    |> Repo.insert()
    |> preload_sheet()
  end

  @spec edit_deck_sheet(DeckSheet.t(), Map.t(), User.t() | nil) ::
          {:ok, DeckSheet.t()} | {:error, any()}
  def edit_deck_sheet(sheet, attrs, user) do
    if can_edit?(sheet, user) do
      do_edit_sheet(sheet, attrs)
    else
      {:error, :insufficient_permissions}
    end
  end

  @spec get_listings(DeckSheet.t(), User.t() | nil) :: {:ok, [DeckSheetListing]} | {:error, any()}
  def get_listings(deck_sheet, user) do
    if can_view?(deck_sheet, user) do
      {:ok, do_get_listings(deck_sheet)}
    else
      {:error, :insufficient_permissions}
    end
  end

  @spec create_deck_sheet_listing(DeckSheet.t(), Deck.t(), User.t() | nil, Map.t()) ::
          {:ok, DeckSheetListing.t()} | {:error, any()}
  def create_deck_sheet_listing(deck_sheet, deck, creator, attrs \\ %{}) do
    if can_edit?(deck_sheet, creator) do
      do_create_deck_sheet_listing(deck_sheet, deck, attrs)
    else
      {:error, :insufficient_permissions}
    end
  end

  @spec edit_deck_sheet_listing(DeckSheetListing.t(), Map.t(), User.t() | nil) ::
          {:ok, DeckSheetListing.t()} | {:error, any()}
  def edit_deck_sheet_listing(listing = %{sheet: sheet}, attrs, editor) do
    if can_edit?(sheet, editor) do
      do_edit_deck_sheet_listing(listing, attrs)
    else
      {:error, :insufficient_permissions}
    end
  end

  defp do_edit_sheet(sheet, attrs) do
    sheet
    |> DeckSheet.changeset(attrs)
    |> Repo.update()
    |> preload_sheet()
  end

  @spec do_get_listings(DeckSheet.t()) :: [DeckSheetListing.t()]
  defp do_get_listings(%{id: id}) do
    query =
      from dsl in DeckSheetListing, where: dsl.deck_sheet_id == ^id, preload: [:deck, :sheet]

    Repo.all(query)
  end

  defp do_create_deck_sheet_listing(sheet, deck, attrs) do
    DeckSheetListing.create(sheet, deck, attrs)
    |> Repo.insert()
    |> preload_listing()
  end

  @spec do_edit_deck_sheet_listing(DeckSheetListing.t(), Map.t()) ::
          {:ok, DeckSheetListing} | {:error, any()}
  defp do_edit_deck_sheet_listing(listing, attrs) do
    listing
    |> DeckSheetListing.changeset(attrs)
    |> Repo.update()
    |> preload_listing()
  end

  @spec can_edit?(DeckSheet.t(), User.t()) :: boolean()
  def can_edit?(%{public_role: :editor}, _user), do: true
  def can_edit?(%{owner_id: owner_id}, %{id: user_id}) when owner_id == user_id, do: true

  def can_edit?(%{group_role: :editor, group: g}, user) when not is_nil(g) do
    UserManager.group_membership(g, user) != nil
  end

  def can_edit?(_, _), do: false

  @spec can_view?(DeckSheet.t(), User.t()) :: boolean()
  def can_view?(%{public_role: pr}, _user) when pr in [:editor, :viewer], do: true
  def can_view?(%{owner_id: owner_id}, %{id: user_id}) when owner_id == user_id, do: true

  def can_view?(%{group_role: gr, group: g}, user)
      when gr in [:editor, :viewer] and not is_nil(g) do
    UserManager.group_membership(g, user) != nil
  end

  def can_view?(_, _), do: false

  @spec preload_sheet({:ok, DeckSheet.t()} | DeckSheet.t() | {:error, any()}) ::
          {:ok, DeckSheet.t()} | {:error, any()}
  defp preload_sheet(sheet_or_tuple), do: preload_tuple(sheet_or_tuple, [:owner, :group])

  @spec preload_listing({:ok, DeckSheetListing.t()} | DeckSheetListing.t() | {:error, any()}) ::
          {:ok, DeckSheetListing.t()} | {:error, any()}
  defp preload_listing(listing_or_tuple), do: preload_tuple(listing_or_tuple, [:sheet, :deck])

  @spec preload_tuple({:ok, arg} | arg | {:error, any()}, [atom()]) ::
          {:ok, arg} | {:error, any()}
        when arg: struct
  defp preload_tuple({:error, error}, _), do: {:error, error}
  defp preload_tuple({:ok, thing}, to_preload), do: {:ok, Repo.preload(thing, to_preload)}
  defp preload_tuple(thing, to_preload), do: {:ok, Repo.preload(thing, to_preload)}
end
