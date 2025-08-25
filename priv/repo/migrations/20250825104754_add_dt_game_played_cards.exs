defmodule Backend.Repo.Migrations.AddDtGamePlayedCards do
  @moduledoc "Add dt game played cards"
  use Ecto.Migration

  def change do
    create table(:dt_game_played_cards) do
      add :game_id, references(:dt_games, on_delete: :delete_all)

      add :player_cards, {:array, :integer}
      add :opponent_cards, {:array, :integer}
      add :player_archetype, :string, default: nil
      add :opponent_archetype, :string, default: nil
      add :archetyping_updated_at, :utc_datetime

      timestamps(updated_at: false)
    end
  end
end
