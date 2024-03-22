defmodule Backend.Repo.Migrations.EnsureIntarray do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS intarray")
  end

  def down do
  end
end
