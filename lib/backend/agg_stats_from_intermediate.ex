defmodule Backend.Repo.Migrations.AggStatsFromIntermediateUpdateMigration do
  @moduledoc "Defines a use macro for updating the aggregation from sql"
  defmacro __using__(_opts) do
    quote do
      use Ecto.Migration

      def up do
        "priv/repo/sql/update_aggregated_stats_from_intermediate.sql"
        |> File.read!()
        |> execute()
      end

      def down do
      end
    end
  end
end
