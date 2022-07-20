defmodule Backend.Repo.Migrations.CardKeywordJoin do
  use Ecto.Migration

  def change do
    create table(:hs_cards_keywords, primary_key: false) do
      add :keyword_id, references(:hs_keywords, on_delete: :delete_all), primary_key: true
      add :card_id, references(:hs_cards, on_delete: :delete_all), primary_key: true
    end
  end
end
