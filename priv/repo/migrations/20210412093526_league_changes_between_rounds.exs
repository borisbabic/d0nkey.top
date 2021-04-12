defmodule Backend.Repo.Migrations.LeagueChangesBetweenRounds do
  use Ecto.Migration

  def change do
    alter(table(:leagues)) do
      add(:changes_between_rounds, :integer, default: 0)
    end
  end
end
