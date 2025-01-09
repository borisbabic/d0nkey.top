defmodule Backend.Repo.Migrations.CreateLogsDtHourlyAggregation do
  use Ecto.Migration

  def change do
    create table(:logs_dt_hourly_aggregation) do
      add :hour_start, :utc_datetime
      add :formats, {:array, :integer}
      add :ranks, {:array, :string}
      add :regions, {:array, :string}

      timestamps(updated_at: false)
    end
  end
end
