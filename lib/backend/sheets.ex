defmodule Backend.Sheets do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Backend.Sheets.DeckSheet
  alias Backend.Sheets.DeckSheetListing
  alias Backend.UserManager
  alias Backend.UserManager.User
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
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

  @spec get_listings(DeckSheet.t(), User.t() | nil, Map.t() | list()) ::
          {:ok, [DeckSheetListing]} | {:error, any()}
  def get_listings(deck_sheet, user, additional_criteria \\ []) do
    if can_view?(deck_sheet, user) do
      {:ok, do_get_listings(deck_sheet, additional_criteria)}
    else
      {:error, :insufficient_permissions}
    end
  end

  def get_listings!(deck_sheet, user, additional_criteria \\ []),
    do: get_listings(deck_sheet, user, additional_criteria) |> Util.bangify()

  def viewable_deck_sheets(user), do: owned_deck_sheets(user) |> add_group_sheets(user, :viewer)

  def contributeable_sheets(user),
    do: owned_deck_sheets(user) |> add_group_sheets(user, :contributor)

  def submittable_sheets(user),
    do: owned_deck_sheets(user) |> add_group_sheets(user, :submitter)

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
    if can_submit?(deck_sheet, creator) do
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
    |> broadcast_sheet_change(:updated_sheet)
  end

  @spec do_get_listings(DeckSheet.t(), Map.t() | list()) :: [DeckSheetListing.t()]
  defp do_get_listings(%{id: id}, additional_criteria) do
    query =
      from(dsl in DeckSheetListing,
        as: :listing,
        where: dsl.sheet_id == ^id,
        preload: [:deck, :sheet]
      )
      |> handle_deck_criteria(additional_criteria)

    Repo.all(query)
  end

  defp join_deck(query) do
    query
    |> join(:inner, [listing: l], d in Deck, on: d.id == l.deck_id, as: :deck)
  end

  defp handle_deck_criteria(query, criteria) do
    Hearthstone.add_deck_criteria(query, criteria, &join_deck/1)
  end

  defp do_create_deck_sheet_listing(sheet, deck, attrs) do
    DeckSheetListing.create(sheet, deck, attrs)
    |> Repo.insert()
    |> preload_listing()
    |> broadcast_listing_change(:inserted_listing)
  end

  @spec do_edit_deck_sheet_listing(DeckSheetListing.t(), Map.t()) ::
          {:ok, DeckSheetListing} | {:error, any()}
  defp do_edit_deck_sheet_listing(listing, attrs) do
    listing
    |> DeckSheetListing.changeset(attrs)
    |> Repo.update()
    |> preload_listing()
    |> broadcast_listing_change(:updated_listing)
  end

  @doc """
  Checks if the user has the minimum role for the sheet for

  ## Example
  iex> Backend.Sheets.has_min_role?(%{owner_id: 1, public_role: :nothing}, %{id: 1}, :contributor)
  true
  iex> Backend.Sheets.has_min_role?(%{owner_id: 1, public_role: :nothing}, %{id: 2}, :contributor)
  false
  iex> Backend.Sheets.has_min_role?(%{public_role: :contributor}, nil, :contributor)
  true
  iex> Backend.Sheets.has_min_role?(%{public_role: :contributor}, nil, :submitter)
  true
  iex> Backend.Sheets.has_min_role?(%{public_role: :submitter}, nil, :submitter)
  true
  iex> Backend.Sheets.has_min_role?(%{public_role: :submitter}, nil, :contributor)
  false
  """
  @spec has_min_role?(DeckSheet.t(), User.t(), DeckSheet.role()) :: boolean()
  def has_min_role?(%{owner_id: owner_id}, %{id: user_id}, _) when owner_id == user_id, do: true

  def has_min_role?(%{group_role: gr, group: g} = sheet, user, min_role) when not is_nil(g) do
    has_min_public_role?(sheet, min_role) or has_min_group_role?(g, gr, user, min_role)
  end

  def has_min_role?(sheet, _user, min_role), do: has_min_public_role?(sheet, min_role)

  def has_min_group_role?(group, group_role, user, min_role) do
    DeckSheet.compare_roles(group_role, min_role) != :lt and
      UserManager.group_membership(group, user) != nil
  end

  def has_min_public_role?(%{public_role: pr}, min_role),
    do: DeckSheet.compare_roles(pr, min_role) != :lt

  def has_min_public_role?(_, _), do: false

  @spec can_admin?(DeckSheet.t(), User.t()) :: boolean()
  def can_admin?(sheet, user), do: has_min_role?(sheet, user, :admin)

  @spec can_contribute?(DeckSheet.t(), User.t()) :: boolean()
  def can_contribute?(sheet, user), do: has_min_role?(sheet, user, :contributor)

  @spec can_submit?(DeckSheet.t(), User.t()) :: boolean()
  def can_submit?(sheet, user), do: has_min_role?(sheet, user, :submitter)

  @spec can_view?(DeckSheet.t(), User.t()) :: boolean()
  def can_view?(sheet, user), do: has_min_role?(sheet, user, :viewer)

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

  def delete_listing(listing = %{sheet: sheet}, user) do
    if can_contribute?(sheet, user) do
      do_delete_listing(listing)
    else
      {:error, :insufficient_permissions}
    end
  end

  defp do_delete_listing(listing) do
    Repo.delete(listing)
    |> broadcast_listing_change(:deleted_listing)
  end

  def delete_sheet(sheet, user) do
    if can_admin?(sheet, user) do
      do_delete_sheet(sheet)
    else
      {:error, :insufficient_permissions}
    end
  end

  defp do_delete_sheet(sheet) do
    Repo.delete(sheet)
    |> broadcast_sheet_change(:deleted_sheet)
  end

  @spec subscribe_to_listings(DeckSheet.t() | integer) :: any()
  def subscribe_to_listings(nil), do: {:error, :cant_subscribe_to_nothing}

  def subscribe_to_listings(sheet_or_id) do
    sheet_or_id
    |> sheets_listings_topic()
    |> BackendWeb.Endpoint.subscribe()
  end

  @spec subscribe_to_sheet(DeckSheet.t() | integer) :: any()
  def subscribe_to_sheet(nil), do: {:error, :cant_subscribe_to_nothing}

  def subscribe_to_sheet(sheet_or_id) do
    sheet_or_id
    |> sheet_topic()
    |> BackendWeb.Endpoint.subscribe()
  end

  defp broadcast_listing_change({:ok, listing}, event) do
    listing.sheet.id
    |> sheets_listings_topic()
    |> BackendWeb.Endpoint.broadcast(to_string(event), listing)

    {:ok, listing}
  end

  defp broadcast_listing_change(result, _event), do: result

  defp broadcast_sheet_change({:ok, sheet}, event) do
    sheet
    |> sheet_topic()
    |> BackendWeb.Endpoint.broadcast(to_string(event), sheet)

    {:ok, sheet}
  end

  defp broadcast_sheet_change(result, _event), do: result

  @spec id(%{id: integer()} | integer()) :: integer()
  defp id(id) when is_integer(id), do: id
  defp id(%{id: id}) when is_integer(id), do: id

  def sheet_topic(sheet_or_id) do
    id = id(sheet_or_id)
    "deck-sheets:sheet:#{id}"
  end

  def sheets_listings_topic(sheet_or_id) do
    id = id(sheet_or_id)
    "deck-sheets:sheet:#{id}:listings"
  end
end
