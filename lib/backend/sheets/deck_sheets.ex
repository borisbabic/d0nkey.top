defmodule Backend.Sheets.DeckSheet do
  @moduledoc "A sheet/list of decks"
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.UserManager.Group
  alias Backend.UserManager.User
  @type t :: %__MODULE__{}
  # order is important, as long as it's possible that each one to the right is a subset of it's preceeding role
  @roles [:admin, :contributor, :submitter, :viewer, :nothing]
  @type role :: :admin | :contributor | :submitter | :viewer | :nothing
  @default_sort "asc_inserted_at"
  schema "deck_sheets" do
    field :name, :string
    belongs_to :owner, User
    belongs_to :group, Group
    field :group_role, Ecto.Enum, values: @roles, default: :contributor
    field :public_role, Ecto.Enum, values: @roles, default: :nothing
    field :extra_columns, {:array, :string}, default: []
    field :default_sort, :string, default: @default_sort
    timestamps()
  end

  @doc false
  def changeset(nil, attrs), do: changeset(%__MODULE__{}, attrs)

  def changeset(deck_sheet, attrs) do
    deck_sheet
    |> cast(attrs, [:name, :group_role, :public_role, :extra_columns, :default_sort])
    |> set_owner(attrs)
    |> set_group(attrs)
    |> validate_required([:owner, :name])
  end

  defp set_owner(c, attrs) do
    owner = Enum.find_value([:owner, "owner"], &Map.get(attrs, &1))
    owner_id? = Enum.any?([:owner_id, "owner_id"], &Map.has_key?(attrs, &1))

    case {owner, owner_id?} do
      {nil, false} ->
        c

      {nil, true} ->
        cast(c, attrs, [:owner_id])

      {owner, _} ->
        c
        |> put_assoc(:owner, owner)
        |> foreign_key_constraint(:owner)
    end
  end

  defp set_group(c, attrs) do
    group = Enum.find_value([:group, "group"], &Map.get(attrs, &1))
    group_id? = Enum.any?([:group_id, "group_id"], &Map.has_key?(attrs, &1))

    case {group, group_id?} do
      {nil, false} ->
        c

      {nil, true} ->
        cast(c, attrs, [:group_id])

      {group, _} ->
        c
        |> put_assoc(:group, group)
        |> foreign_key_constraint(:group)
    end
  end

  def available_roles(), do: @roles

  def role_display(role), do: role |> to_string() |> Recase.to_title()

  @doc """
  Compares the two roles, returning whether the first one is :gt (superset of), :lt (subset of) or :wq to the second one
  Unknown roles are considered less than known roles

  ## Example
  iex> Backend.Sheets.DeckSheet.compare_roles(:admin, :nothing)
  :gt
  iex> Backend.Sheets.DeckSheet.compare_roles(:submitter, :contributor)
  :lt
  iex> Backend.Sheets.DeckSheet.compare_roles(:viewer, :viewer)
  :eq
  """
  @spec compare_roles(role(), role()) :: :gt | :lt | :eq
  def compare_roles(role_one, role_two) do
    first_index = Enum.find_index(@roles, &(&1 == role_one))
    second_index = Enum.find_index(@roles, &(&1 == role_two))

    cond do
      first_index == second_index -> :eq
      first_index == nil -> :lt
      second_index == nil -> :gt
      # swapped because coming sooner, ie smaller index, means it's greater
      first_index > second_index -> :lt
      first_index < second_index -> :gt
    end
  end

  @spec sort_listings([Backend.Sheets.DeckSheetListing.t()], String.t() | t()) :: [
          Backend.Sheets.DeckSheetListing.t()
        ]
  def sort_listings(listings, %{default_sort: sort}), do: sort_listings(listings, sort)

  def sort_listings(listings, sort_slug) do
    {direction, field_slug} = BackendWeb.SortHelper.split_sort_slug(sort_slug)
    listing_sorter = create_listing_sorter(field_slug)
    Enum.sort_by(listings, listing_sorter, direction)
  end

  defp create_listing_sorter("deck_class") do
    fn %{deck: deck} -> Backend.Hearthstone.Deck.class(deck) end
  end

  defp create_listing_sorter(field)
       when field in ["inserted_at", "udpated_at", :inserted_at, :updated_at] do
    fn l -> Util.get(l, field) |> to_string() end
  end

  defp create_listing_sorter(field_slug) do
    fn l -> Util.get(l, field_slug) end
  end

  @spec listing_sort_options(t()) :: {name :: String.t(), slug :: String.t()}
  def listing_sort_options(sheet) do
    fields = ["inserted_at", "deck_class", "comment", "source" | extra_column_fields(sheet)]

    for field <- fields, direction <- ["asc", "desc"] do
      slug = "#{direction}_#{field}"
      {listing_sort_name(slug), slug}
    end
  end

  def listing_sort_name(sort_option) do
    BackendWeb.SortHelper.sort_name(sort_option, &sort_field_name/1)
  end

  def sort_field_name("comment"), do: "Comment"
  def sort_field_name("source"), do: "Source"
  def sort_field_name("deck_class"), do: "Deck Class"
  def sort_field_name(other), do: other

  def extra_column_fields(%{extra_columns: %{} = extra_columns}), do: Map.keys(extra_columns)
  def extra_column_fields(_), do: []

  def default_sort(), do: @default_sort
end
