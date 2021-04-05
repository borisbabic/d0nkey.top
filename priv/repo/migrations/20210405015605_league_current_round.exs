defmodule Backend.Repo.Migrations.LeagueCurrentRound do
  use Ecto.Migration

  def change do
    alter table(:leagues) do
      add(:current_round, :integer, default: 1)
    end
  end
end
