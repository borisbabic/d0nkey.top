defmodule Backend.Repo.Migrations.AddStats do
  use Ecto.Migration

  def change do
    create table(:qualifier_stats) do
      add :tour_stop, :string, null: false
      add :region, :string, null: false
      add :cups_counted, :integer, default: 0
      add :player_stats, {:array, :map}, default: []
      timestamps()
    end
  end
end
