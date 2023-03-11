defmodule Backend.Repo.Migrations.DeckSideboards do
  use Ecto.Migration

  def change do
    alter table(:deck) do
      add :sideboards, {:array, :map}, []
    end
  end
end
