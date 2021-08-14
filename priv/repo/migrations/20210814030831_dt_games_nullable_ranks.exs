defmodule Backend.Repo.Migrations.DtGamesNullableRanks do
  use Ecto.Migration

  def change do
    alter table(:dt_games) do
      modify(:player_rank, :integer, null: true, from: :integer)
      modify(:opponent_rank, :integer, null: true, from: :integer)
    end
  end
end
