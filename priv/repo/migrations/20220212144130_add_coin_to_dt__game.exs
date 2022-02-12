defmodule Backend.Repo.Migrations.AddCoinToDt_Game do
  use Ecto.Migration

  def change do
    alter(table(:dt_games)) do
      add(:player_has_coin, :boolean, default: nil, null: true)
    end
  end
end
