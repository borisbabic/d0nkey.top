defmodule Backend.Repo.Migrations.CreateBattletagInfo do
  use Ecto.Migration

  def change do
    create table(:battletag_info) do
      add :battletag_full, :string
      add :battletag_short, :string
      add :country, :string
      add :priority, :integer
      add :reported_by, :string

      timestamps()
    end
  end
end
