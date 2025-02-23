defmodule Backend.Repo.Migrations.AddDayToIntermiediateLogs do
  use Ecto.Migration

  def change do
    alter table(:logs_dt_intermediate_agg) do
      add :day, :date, null: true
      modify :hour_start, :utc_datetime, null: true
    end
  end
end
