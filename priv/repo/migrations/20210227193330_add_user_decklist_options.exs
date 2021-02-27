defmodule Backend.Repo.Migrations.AddUserDecklistOptions do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :decklist_options, :map, default: %{}
    end
  end
end
