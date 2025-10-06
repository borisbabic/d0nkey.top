defmodule Backend.Repo.Migrations.CardBannedFromSideboard do
  use Ecto.Migration

  def change do
    alter table(:hs_cards) do
      add :banned_from_sideboard, :boolean, default: false
    end
  end
end
