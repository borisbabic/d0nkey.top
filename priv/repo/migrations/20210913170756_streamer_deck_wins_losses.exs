defmodule Backend.Repo.Migrations.StreamerDeckWinsLosses do
  use Ecto.Migration

  def change do
    alter table(:streamer_deck) do
      add(:wins, :integer, default: 0)
      add(:losses, :integer, default: 0)
    end
  end
end
