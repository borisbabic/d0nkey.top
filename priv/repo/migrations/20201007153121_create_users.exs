defmodule Backend.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :battletag, :string
      add :bnet_id, :integer

      timestamps()
    end

    create unique_index(:users, [:bnet_id])
  end
end
