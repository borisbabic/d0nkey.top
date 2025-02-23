defmodule Backend.Repo.Migrations.AddDayStartToIntermediateAgg do
  use Ecto.Migration

  def change do
    alter table(:dt_intermediate_agg_stats) do
      add :day, :date, null: true
    end
  end
end
