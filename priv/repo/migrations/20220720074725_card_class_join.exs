defmodule Backend.Repo.Migrations.CardClassJoin do
  use Ecto.Migration

  def change do
    create table(:hs_cards_classes, primary_key: false) do
      add :class_id, references(:hs_classes, on_delete: :delete_all), primary_key: true
      add :card_id, references(:hs_cards, on_delete: :delete_all), primary_key: true
    end
  end
end
