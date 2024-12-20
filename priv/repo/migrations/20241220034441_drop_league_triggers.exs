defmodule Backend.Repo.Migrations.DropLeagueTriggers do
  use Ecto.Migration

  def up do
    execute("DROP TRIGGER IF EXISTS notify_leagues_id_changes_trigger ON dt_games")
  end

  def down do
  end
end
