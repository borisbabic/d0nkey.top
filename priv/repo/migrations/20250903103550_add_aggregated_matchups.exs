defmodule Backend.Repo.Migrations.AddAggregatedMatchups do
  use Ecto.Migration

  def change do
    create table(:dt_aggregated_matchups) do
      add :matchups_version, :integer, default: 1
      add :matchups, :binary
      add :period, :string
      add :rank, :string
      add :format, :integer
      timestamps()
    end

    create(unique_index(:dt_aggregated_matchups, [:matchups_version, :period, :rank, :format]))
  end
end
