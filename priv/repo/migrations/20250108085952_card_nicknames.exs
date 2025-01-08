defmodule Backend.Repo.Migrations.CardNicknames do
  use Ecto.Migration

  def change do
    alter table(:hs_cards) do
      add :nicknames, {:array, :string}, default: []
    end
  end
end
