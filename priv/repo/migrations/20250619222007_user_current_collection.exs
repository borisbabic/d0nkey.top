defmodule Backend.Repo.Migrations.UserCurrentCollection do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :current_collection_id, references(:hs_collections, type: :uuid)
    end
  end
end
