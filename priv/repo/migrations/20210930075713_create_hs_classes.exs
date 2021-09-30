defmodule Backend.Repo.Migrations.CreateHsClasses do
  use Ecto.Migration

  def change do
    create table(:hs_classes) do
      add :name, :string
      add :slug, :string
      add :alternate_hero_card_ids, {:array, :integer}
      add :card_id, :integer
      add :hero_power_card_id, :integer

      timestamps()
    end
  end
end
