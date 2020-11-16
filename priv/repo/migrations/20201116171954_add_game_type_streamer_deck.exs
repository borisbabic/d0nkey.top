defmodule Backend.Repo.Migrations.AddGameTypeStreamerDeck do
  use Ecto.Migration

  def change do
    alter table(:streamer_deck) do
      add :game_type, :integer, null: true
    end
  end
end
