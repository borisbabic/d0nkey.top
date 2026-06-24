defmodule Backend.Repo.Migrations.AddCardMaxSideboardedCards do
  use Ecto.Migration

  def change do
    alter table(:hs_cards) do
      add :max_sideboard_cards, :integer, default: nil
    end
  end
end
