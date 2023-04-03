defmodule Backend.Sheets.DeckSheet do
  @moduledoc "A sheet/list of decks"
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.UserManager.Group
  alias Backend.UserManager.User
  @type t :: %__MODULE__{}
  @roles [:editor, :viewer, :nothing]
  schema "deck_sheets" do
    field :name, :string
    belongs_to :owner, User
    belongs_to :group, Group
    field :group_role, Ecto.Enum, values: @roles, default: :editor
    field :public_role, Ecto.Enum, values: @roles, default: :nothing
    field :extra_columns, {:array, :string}, default: []

    timestamps()
  end

  @doc false
  def changeset(deck_sheet, attrs) do
    deck_sheet
    |> cast(attrs, [:name, :group_role, :public_role, :extra_columns])
    |> set_owner(attrs)
    |> set_group(attrs)
    |> validate_required([:owner, :name])
  end

  defp set_owner(c, %{owner: owner}), do: set_owner(c, owner)

  defp set_owner(c, owner = %{id: _}) do
    c
    |> put_assoc(:owner, owner)
    |> foreign_key_constraint(:owner)
  end

  defp set_owner(c, _attrs), do: c

  defp set_group(c, %{group: group}), do: set_group(c, group)

  defp set_group(c, group = %{id: _}) do
    c
    |> put_assoc(:group, group)
    |> foreign_key_constraint(:group)
  end

  defp set_group(c, _attrs), do: c
end
