defmodule Backend.Repo.Migrations.CreateGroupMemberships do
  use Ecto.Migration

  def change do
    create table(:group_memberships) do
      add :role, :string
      add :group_id, references(:groups, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:group_memberships, [:group_id])
    create index(:group_memberships, [:user_id])
    create unique_index(:group_memberships, [:group_id, :user_id], name: :group_memberships_group_user)
  end
end
