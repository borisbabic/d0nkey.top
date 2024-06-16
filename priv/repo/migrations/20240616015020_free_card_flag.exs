defmodule Backend.Repo.Migrations.FreeCardFlag do
  use Ecto.Migration

  def change do
    alter table(:hs_cards) do
      add :dust_free, :boolean, default: false, null: false
    end
  end
end
