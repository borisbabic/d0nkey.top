defmodule Backend.Repo.Migrations.RemoveObanTables do
  use Ecto.Migration

  def up do
    Oban.Migrations.down()
  end

  def down do
  end
end
