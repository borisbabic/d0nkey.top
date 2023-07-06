defmodule Backend.Repo.Migrations.GameRawPlayerCardStats do
  use Ecto.Migration

  def change do
    create table("dt_raw_player_card_stats") do
      add :game_id, references(:dt_games, on_delete: :nothing), null: false
      add :cards_drawn_from_initial_deck, {:array, :map}
      add :cards_in_hand_after_mulligan, {:array, :map}
    end
  end
end
