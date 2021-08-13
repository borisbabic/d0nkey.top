defmodule Backend.Repo.Migrations.DtGamesClasses do
  use Ecto.Migration

  def change do
    alter table(:dt_games) do
      add :player_class, :string
      add :opponent_class, :string
    end
  end
end
