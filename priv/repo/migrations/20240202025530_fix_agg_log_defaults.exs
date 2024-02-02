defmodule Backend.Repo.Migrations.FixAggLogDefaults do
  use Ecto.Migration

  def change do
    alter table(:logs_dt_aggregation) do
      modify :formats, {:array, :integer}, default: [], null: false
      modify :ranks, {:array, :string}, default: [], null: false
      modify :periods, {:array, :string}, default: [], null: false
    end
  end
end
