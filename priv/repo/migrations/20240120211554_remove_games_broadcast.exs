defmodule Backend.Repo.Migrations.RemoveGamesBroadcast do
  use Ecto.Migration

  def up do
    execute("DROP TRIGGER notify_dt_games_id_changes_trigger ON dt_games")
  end

  def down do
  end
end
