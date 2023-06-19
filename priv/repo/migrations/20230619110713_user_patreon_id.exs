defmodule Backend.Repo.Migrations.UserPatreonId do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :patreon_id, :string
    end

    create(unique_index(:users, [:patreon_id], name: :user_patreon_id_unique))
  end
end
