defmodule Backend.Repo.Migrations.AddQualifier do
  use Ecto.Migration

  def change() do
    create table(:qualifier) do
      add :tour_stop, :string, null: false
      add :start_time, :utc_datetime, null: false
      add :end_time, :utc_datetime, null: true
      add :region, :string, null: false
      add :tournament_id, :string, null: false
      add :tournament_slug, :string, null: false
      add :winner, :string, null: true
      add :type, :string, null: false
      add :standings, {:array, :map}, default: []
      timestamps()
    end
  end
end
