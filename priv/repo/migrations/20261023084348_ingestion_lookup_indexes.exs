defmodule Backend.Repo.Migrations.IngestionLookupIndexes do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    # UserManager.get_by_btag/1 runs for every uploaded deck tracker game
    create_if_not_exists index(:users, [:battletag], concurrently: true)

    # Hearthstone.decks_from_parts/4 runs when a game's deckcode isn't found
    create_if_not_exists index(:deck, ["sort_asc(cards)"],
                           name: :deck_sorted_cards_index,
                           concurrently: true
                         )
  end
end
