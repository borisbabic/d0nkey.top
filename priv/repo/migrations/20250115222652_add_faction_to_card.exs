defmodule Backend.Repo.Migrations.AddFactionToCard do
  use Ecto.Migration

  def change do
    create table(:hs_cards_factions, primary_key: false) do
      add :faction_id, references(:hs_factions, on_delete: :delete_all), primary_key: true
      add :card_id, references(:hs_cards, on_delete: :delete_all), primary_key: true
    end
  end
end
