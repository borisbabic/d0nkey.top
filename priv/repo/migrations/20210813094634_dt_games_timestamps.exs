defmodule Backend.Repo.Migrations.DtGamesTimestamps do
  use Ecto.Migration

  def change do
    alter table(:dt_games) do
      timestamps()
    end
  end
end
