defmodule Backend.Repo.Migrations.AddExtraCardSetMapper do
  use Ecto.Migration

  def change do
    create table(:hs_extra_card_set, primary_key: false) do
      add :card_id, references(:hs_cards, on_delete: :delete_all), primary_key: true
      add :card_set_id, references(:hs_sets, on_delete: :delete_all), primary_key: true
    end

    create(
      unique_index(:hs_extra_card_set, [:card_set_id, :card_id],
        name: :hs_extra_card_set_unique_index
      )
    )
  end
end
