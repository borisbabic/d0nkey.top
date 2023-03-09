defmodule Backend.Repo.Migrations.DeckDeckcodeUniqueness do
  use Ecto.Migration

  def change do
    create(unique_index(:deck, [:deckcode], name: :deck_deckcode_unique_index))
  end
end
