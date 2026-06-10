defmodule Backend.Repo.Migrations.AddCardDeckSizeMod do
  use Ecto.Migration

  def change do
    alter table(:hs_cards) do
      add :deck_size_mod, :integer, default: nil
    end
  end
end
