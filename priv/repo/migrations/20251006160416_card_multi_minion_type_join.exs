defmodule Backend.Repo.Migrations.CardMultiMinionTypeJoin do
  use Ecto.Migration

  def change do
    create table(:hs_cards_multi_minion_types, primary_key: false) do
      add :minion_type_id, references(:hs_minion_types, on_delete: :delete_all), primary_key: true
      add :card_id, references(:hs_cards, on_delete: :delete_all), primary_key: true
    end
  end
end
