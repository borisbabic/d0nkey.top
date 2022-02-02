defmodule Backend.Repo.Migrations.CreateOldBattletags do
  use Ecto.Migration

  def change do
    create table(:old_battletags) do
      add :user_id, references(:users, on_delete: :nothing), null: true
      add :new_battletag, :string, null: false
      add :old_battletag, :string, null: false
      add :new_battletag_short, :string, null: false
      add :old_battletag_short, :string, null: false
      add :source, :string, null: false

      timestamps()
    end

    create index(:old_battletags, [:user_id])
  end
end
