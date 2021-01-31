defmodule Backend.Repo.Migrations.AddBattlefySlug do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :battlefy_slug, :string
    end
  end
end
