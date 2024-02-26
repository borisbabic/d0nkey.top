defmodule Backend.Repo.Migrations.AddPatreonTierToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :patreon_tier_id, references(:patreon_tiers, on_delete: :delete_all, type: :string),
        null: true
    end
  end
end
