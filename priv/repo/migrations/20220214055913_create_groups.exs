defmodule Backend.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :owner_id, references(:users, on_delete: :nothing)
      add :join_code, :uuid, null: false
      add :discord, :string, null: true

      timestamps()
    end

    create index(:groups, [:owner_id])
  end
end
