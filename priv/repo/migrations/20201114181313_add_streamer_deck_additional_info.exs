defmodule Backend.Repo.Migrations.AddStreamerDeckAdditionalInfo do
  use Ecto.Migration

  def change do
    alter table(:streamer_deck) do
      add :worst_legend_rank, :integer, null: false, default: 0
      add :latest_legend_rank, :integer, null: false, default: 0
      add :minutes_played, :integer, null: false, default: 0
    end
  end
end
