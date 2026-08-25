defmodule Backend.Repo.Migrations.AddCodesToGiveawaysAndEntries do
  use Ecto.Migration

  def change do
    alter table(:giveaways) do
      add :codes, {:array, :text}, default: []
    end

    alter table(:giveaway_entries) do
      add :code, :text
    end
  end
end
