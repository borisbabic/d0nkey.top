defmodule Backend.Sheets.DeckSheet do
  @moduledoc "A sheet/list of decks"
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.UserManager.Group
  alias Backend.UserManager.User
  @type t :: %__MODULE__{}
  @roles [:admin, :contributor, :viewer, :nothing]
  schema "deck_sheets" do
    field :name, :string
    belongs_to :owner, User
    belongs_to :group, Group
    field :group_role, Ecto.Enum, values: @roles, default: :contributor
    field :public_role, Ecto.Enum, values: @roles, default: :nothing
    field :extra_columns, {:array, :string}, default: []

    timestamps()
  end

  @doc false
  def changeset(nil, attrs), do: changeset(%__MODULE__{}, attrs)

  def changeset(deck_sheet, attrs) do
    deck_sheet
    |> cast(attrs, [:name, :group_role, :public_role, :extra_columns])
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
end
