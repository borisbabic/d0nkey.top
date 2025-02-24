defmodule Backend.Repo.Migrations.NewAggLogs do
  use Ecto.Migration

  def change do
    create table(:logs_dt_new_agg) do
      add :formats, {:array, :integer}, default: [], null: false
      add :ranks, {:array, :string}, default: [], null: false
      add :periods, {:array, :string}, default: [], null: false
      add :regions, {:array, :string}, default: []

      timestamps(updated_at: false)
    end
  end
end
