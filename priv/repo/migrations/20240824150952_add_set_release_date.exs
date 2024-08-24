defmodule Backend.Repo.Migrations.AddSetReleaseDate do
  use Ecto.Migration

  def change do
    alter table(:hs_sets) do
      add :release_date, :date, null: true
    end
  end
end
