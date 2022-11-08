defmodule Backend.Repo.Migrations.EntryMaterializedView do
  use Ecto.Migration

  def change do
    execute("""
      CREATE MATERIALIZED VIEW leaderboards_entry_latest AS
        SELECT rank, season_id, MAX(inserted_at) as inserted_at
        FROM public.leaderboards_entry
        GROUP BY season_id, rank
    """)
  end
end
