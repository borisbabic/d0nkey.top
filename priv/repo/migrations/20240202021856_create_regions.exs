defmodule Backend.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:dt_regions) do
      add :code, :string
      add :display, :string
      add :auto_aggregate, :boolean, default: false, null: false

      timestamps()
    end
  end
end
