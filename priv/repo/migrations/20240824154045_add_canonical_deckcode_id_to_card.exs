defmodule Backend.Repo.Migrations.AddCanonicalDeckcodeIdToCard do
  use Ecto.Migration

  def change do
    alter table(:hs_cards) do
      add :canonical_id, references(:hs_cards, on_delete: :nothing)
      add :deckcode_copy_id, references(:hs_cards, on_delete: :nothing)
    end
  end
end
