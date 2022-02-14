defmodule Backend.UserManager.GroupMembership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.UserManager.Group

  schema "group_memberships" do
    field :role, :string
    belongs_to :group, Group
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(group_membership, attrs) do
    group_membership
    |> cast(attrs, [:role])
    |> set_assoc(attrs, :group)
    |> set_assoc(attrs, :user)
    |> validate_required([:role])
  end

  defp set_assoc(c, attrs, attr) do
    case Map.get(attrs, attr) do
      nil -> c
      val ->
        c
        |> put_assoc(attr, val)
        |> foreign_key_constraint(attr)
    end
  end

  def owner?(%{group: %{owner_id: owner_id}, user_id: user_id}),
    do: owner_id == user_id

  def owner?(%{role: "Owner"}), do: true
  def owner?(_), do: false

  def admin?(m = %{role: r}),
    do: owner?(m) || r in ["Admin"]

  def admin?(_), do: false
end
