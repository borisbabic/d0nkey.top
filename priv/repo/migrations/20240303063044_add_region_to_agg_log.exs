defmodule Backend.Repo.Migrations.AddRegionToAggLog do
  use Ecto.Migration

  def change do
    alter table(:logs_dt_aggregation) do
      add :regions, {:array, :string}, default: []
    end
  end
end
