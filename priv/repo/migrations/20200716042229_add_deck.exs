defmodule Backend.Repo.Migrations.AddDeck do
  use Ecto.Migration

  def change do
    create table(:deck) do
      add :cards, {:array, :integer}, default: []
      add :deckcode, :string, null: false
      add :format, :integer, null: false
      add :hero, :integer, null: false
      timestamps()
    end

    create(unique_index(:deck, [:deckcode], name: :deck_deckcode_unique_index))
  end
end
