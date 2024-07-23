defmodule Backend.Repo.Migrations.DeckDustCost do
  use Ecto.Migration

  def change do
    alter table(:deck) do
      add :cost, :integer, default: nil
    end
  end
end
