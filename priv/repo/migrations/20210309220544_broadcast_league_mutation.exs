defmodule Backend.Repo.Migrations.BroadcastLeagueMutation do
  use PostgrexPubsub.BroadcastIdMigration, table_name: "leagues"
end
