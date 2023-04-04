defmodule Backend.Sheets do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Backend.Sheets.DeckSheet
  alias Backend.Sheets.DeckSheetListing
  alias Backend.UserManager
  alias Backend.UserManager.User
  alias Backend.Repo

  @spec create_deck_sheet(User.t(), String.t(), Map.t()) ::
          {:ok, DeckSheet.t()} | {:error, any()}
  def create_deck_sheet(owner, name, other_attrs \\ %{}) do
    attrs =
      for {key, val} <- other_attrs,
          into: %{"owner" => owner, "name" => name},
          do: {to_string(key), val}

    DeckSheet.changeset(%DeckSheet{}, attrs)
    |> Repo.insert()
    |> preload_sheet()
  end

  @spec edit_deck_sheet(DeckSheet.t(), Map.t(), User.t() | nil) ::
          {:ok, DeckSheet.t()} | {:error, any()}
  def edit_deck_sheet(sheet, attrs, user) do
    if can_admin?(sheet, user) do
      do_edit_sheet(sheet, attrs)
    else
      {:error, :insufficient_permissions}
    end
  end

  def get_sheet(sheet_id) do
    query = from ds in DeckSheet, where: ds.id == ^sheet_id, preload: [:group, :owner]
    Repo.one(query)
  end

  @spec get_listings(DeckSheet.t(), User.t() | nil) :: {:ok, [DeckSheetListing]} | {:error, any()}
  def get_listings(deck_sheet, user) do
    if can_view?(deck_sheet, user) do
      {:ok, do_get_listings(deck_sheet)}
    else
      {:error, :insufficient_permissions}
    end
  end

  def get_listings!(deck_sheet, user), do: get_listings(deck_sheet, user) |> Util.bangify()

  def viewable_deck_sheets(user), do: owned_deck_sheets(user) |> add_group_sheets(user, :viewer)

  def contributeable_sheets(user),
    do: owned_deck_sheets(user) |> add_group_sheets(user, :contributor)

  defp add_group_sheets(previous, user, min_role) do
    (previous ++ group_sheets(user, min_role))
    |> Enum.uniq_by(& &1.id)
  end

  def group_sheets(user, min_role) do
    possible_roles = possible_roles(min_role)

    query =
      from ds in DeckSheet,
        inner_join: gm in Backend.UserManager.GroupMembership,
        on: gm.group_id == ds.group_id and gm.user_id == ^user.id,
        where: ds.group_role in ^possible_roles,
        preload: [:owner, :group]

    Repo.all(query)
  end

  defp possible_roles(min_role) do
    DeckSheet.available_roles()
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 != min_role))

    # will also return empty if min_role not available
  end

  def owned_deck_sheets(%User{id: id}) do
    query = from ds in DeckSheet, where: ds.owner_id == ^id, preload: [:owner, :group]

    Repo.all(query)
  end

  @spec create_deck_sheet_listing(DeckSheet.t(), Deck.t(), User.t() | nil, Map.t()) ::
          {:ok, DeckSheetListing.t()} | {:error, any()}
  def create_deck_sheet_listing(deck_sheet, deck, creator, attrs \\ %{}) do
    if can_contribute?(deck_sheet, creator) do
      do_create_deck_sheet_listing(deck_sheet, deck, attrs)
    else
      {:error, :insufficient_permissions}
    end
  end

  @spec edit_deck_sheet_listing(DeckSheetListing.t(), Map.t(), User.t() | nil) ::
          {:ok, DeckSheetListing.t()} | {:error, any()}
  def edit_deck_sheet_listing(listing = %{sheet: sheet}, attrs, editor) do
    if can_contribute?(sheet, editor) do
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
    query = from dsl in DeckSheetListing, where: dsl.sheet_id == ^id, preload: [:deck, :sheet]

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

  @spec can_admin?(DeckSheet.t(), User.t()) :: boolean()
  def can_admin?(nil, _user), do: true
  def can_admin?(%{public_role: :admin}, _user), do: true
  def can_admin?(%{owner_id: owner_id}, %{id: user_id}) when owner_id == user_id, do: true

  def can_admin?(%{group_role: :admin, group: g}, user) when not is_nil(g) do
    UserManager.group_membership(g, user) != nil
  end

  def can_admin?(_, _), do: false

  @spec can_contribute?(DeckSheet.t(), User.t()) :: boolean()
  def can_contribute?(%{public_role: pr}, _user) when pr in [:admin, :contributor], do: true
  def can_contribute?(%{owner_id: owner_id}, %{id: user_id}) when owner_id == user_id, do: true

  def can_contribute?(%{group_role: gr, group: g}, user)
      when gr in [:admin, :contributor] and not is_nil(g) do
    UserManager.group_membership(g, user) != nil
  end

  def can_contribute?(_, _), do: false

  @spec can_view?(DeckSheet.t(), User.t()) :: boolean()
  def can_view?(%{public_role: pr}, _user) when pr in [:admin, :contributor, :viewer], do: true
  def can_view?(%{owner_id: owner_id}, %{id: user_id}) when owner_id == user_id, do: true

  def can_view?(%{group_role: gr, group: g}, user)
      when gr in [:admin, :contributor, :viewer] and not is_nil(g) do
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
