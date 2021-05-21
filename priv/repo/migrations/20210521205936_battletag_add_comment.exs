defmodule Backend.Repo.Migrations.BattletagAddComment do
  use Ecto.Migration

  def change do
    alter(table(:battletag_info)) do
      add(:comment, :text)
    end
  end
end
