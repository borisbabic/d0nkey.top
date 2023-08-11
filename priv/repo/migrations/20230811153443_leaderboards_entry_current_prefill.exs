defmodule Backend.Repo.Migrations.LeaderboardsEntryCurrentPrefill do
  use Ecto.Migration

  def change do
    sql = """
      INSERT INTO public.leaderboards_current_entries (rank, account_id, rating, season_id, inserted_at)
      SELECT DISTINCT le.rank, le.account_id, le.rating, le.season_id, le.inserted_at 
      FROM public.leaderboards_entry le
      INNER JOIN public.leaderboards_entry_latest lat
      ON lat.season_id = le.season_id AND lat.rank = le.rank AND lat.inserted_at = le.inserted_at;
    """

    delete_sql = """
    DELETE FROM public.leaderboards_current_entries le 
    """

    execute(sql, delete_sql)
  end
end
