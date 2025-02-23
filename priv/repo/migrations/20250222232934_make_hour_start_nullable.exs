defmodule Backend.Repo.Migrations.MakeHourStartNullable do
  use Ecto.Migration

  def change do
    alter table(:dt_intermediate_agg_stats) do
      modify(:hour_start, :utc_datetime, null: true, default: nil)
    end
  end
end
