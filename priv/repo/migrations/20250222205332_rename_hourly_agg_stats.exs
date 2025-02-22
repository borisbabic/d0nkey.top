defmodule Backend.Repo.Migrations.RenameHourlyAggStats do
  use Ecto.Migration

  def change do
    rename table("dt_hourly_aggregated_stats"), to: table("dt_intermediate_agg_stats")
  end
end
