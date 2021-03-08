defmodule Backend.Repo.Migrations.AddLeagueJoinCode do
  use Ecto.Migration

  def change do
    alter table(:leagues) do
      add :join_code, :uuid, null: false
    end
  end
end
