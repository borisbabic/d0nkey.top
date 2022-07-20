defmodule Backend.Repo.Migrations.HearthstoneCard do
  use Ecto.Migration

  def change do
    create table(:hs_cards) do
      add :name, :string
      add :artist_name, :string, default: nil
      add :attack, :integer, default: nil
      add :card_set_id, references(:hs_sets, on_delete: :nilify_all)
      add :card_type_id, references(:hs_type, on_delete: :nilify_all)
      add :child_ids, {:array, :integer}, default: []
      add :collectible, :boolean, default: false
      add :copy_of_card_id, :integer
      add :crop_image, :string, default: nil
      add :durability, :integer, default: nil
      add :duels_constructed, :boolean, default: false
      add :duels_relevant, :boolean, default: false
      add :flavor_text, :string, default: nil
      add :health, :integer, default: nil
      add :image, :string, default: nil
      add :image_gold, :string, default: nil
      add :mana_cost, :integer, default: nil
      add :minion_type_id, references(:hs_minion_types, on_delete: :nilify_all)
      add :rarity_id, references(:hs_rarities, on_delete: :nilify_all)
      add :slug, :string, default: nil
      add :spell_school_id, references(:hs_spell_schools, on_delete: :nilify_all)
      add :text, :string, default: nil

      timestamps()
    end
  end
end
