defmodule Backend.UserManager.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User

  schema "groups" do
    field :name, :string
    belongs_to :owner, User
    field :join_code, Ecto.UUID, autogenerate: true
    field :discord, :string, default: nil

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :discord])
    |> set_owner(attrs, group)
    |> validate_required([:name])
  end

  defp set_owner(c, %{owner: owner}, _), do: set_owner(c, owner)
  defp set_owner(c, %{"owner" => owner}, _), do: set_owner(c, owner)
  defp set_owner(c, _, %{owner: owner = %{id: _}}), do: set_owner(c, owner)
  defp set_owner(c, _, _), do: c

  defp set_owner(c, owner = %{id: _}) do
    c
    |> put_assoc(:owner, owner)
    |> foreign_key_constraint(:owner)
  end

  def inc_updated_at(l) do
    attrs = %{updated_at: NaiveDateTime.utc_now()}

    l |> cast(attrs, [:updated_at])
  end
end
