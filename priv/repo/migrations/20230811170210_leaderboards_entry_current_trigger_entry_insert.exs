defmodule Backend.Repo.Migrations.LeaderboardsEntryCurrentTriggerEntryInsert do
  use Ecto.Migration

  def change do
    up = """
    create trigger insert_entry
      after
    update or insert
      on
      public.leaderboards_current_entries
      for each row
      execute procedure public.insert_entry();
    """

    down = "DROP trigger insert_entry ON public.leaderboards_current_entries"
    execute(up, down)
  end
end
