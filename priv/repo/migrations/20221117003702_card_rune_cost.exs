defmodule Backend.Repo.Migrations.CardRuneCost do
  use Ecto.Migration

  def change do
    alter table(:hs_cards) do
      add :rune_cost, :map
    end
  end
end
