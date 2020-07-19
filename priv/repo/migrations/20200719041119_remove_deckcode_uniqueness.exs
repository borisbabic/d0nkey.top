defmodule Backend.Repo.Migrations.RemoveDeckcodeUniqueness do
  use Ecto.Migration

  def change do
    drop(unique_index(:deck, [:deckcode], name: :deck_deckcode_unique_index))
  end
end
