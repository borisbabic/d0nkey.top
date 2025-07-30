defmodule Backend.Repo.Migrations.RenameGuildBattletags do
  use Ecto.Migration

  def change do
    rename table("guild_battletags"), to: table("guild_config")
  end
end
