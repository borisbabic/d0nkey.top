defmodule Backend.Repo.Migrations.CreateGiveawayEntries do
  use Ecto.Migration

  def change do
    create table(:giveaway_entries) do
      add :giveaway_id, references(:giveaways, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :winner, :boolean, default: false

      timestamps()
    end

    create index(:giveaway_entries, [:giveaway_id])
    create index(:giveaway_entries, [:user_id])
    create unique_index(:giveaway_entries, [:giveaway_id, :user_id])
  end
end
