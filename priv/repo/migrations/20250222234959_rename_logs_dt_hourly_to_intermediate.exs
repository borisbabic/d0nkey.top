defmodule Backend.Repo.Migrations.RenameLogsDtHourlyToIntermediate do
  use Ecto.Migration

  def change do
    rename table("logs_dt_hourly_aggregation"), to: table("logs_dt_intermediate_agg")
  end
end
