defmodule Backend.Repo.Migrations.LeaderboardsEntryCurrentSuppressRedundantUpdates do
  use Ecto.Migration

  def change do
    up = """
    CREATE TRIGGER no_redundant_updates
    BEFORE UPDATE ON public.leaderboards_current_entries 
    FOR EACH ROW EXECUTE FUNCTION suppress_redundant_updates_trigger();
    """

    down = "DROP trigger no_redundant_updates ON public.leaderboards_current_entries;"

    execute(up, down)
  end
end
