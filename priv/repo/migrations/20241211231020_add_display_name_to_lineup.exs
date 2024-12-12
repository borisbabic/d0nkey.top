defmodule Backend.Repo.Migrations.AddDisplayNameToLineup do
  use Ecto.Migration

  def change do
    alter table(:lineups) do
      add :display_name, :string, nil: true, default: nil
    end
  end
end
