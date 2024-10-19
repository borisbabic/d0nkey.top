defmodule Backend.Repo.Migrations.ObanVer12Migration do
  use Ecto.Migration

  def up, do: Oban.Migrations.up(version: 12)

  def down, do: Oban.Migrations.down(version: 12)
end
