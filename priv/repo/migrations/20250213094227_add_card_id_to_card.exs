defmodule Backend.Repo.Migrations.AddCardIdToCard do
  use Ecto.Migration

  def change do
    alter table(:hs_cards) do
      add :card_id, :string
    end
  end
end
