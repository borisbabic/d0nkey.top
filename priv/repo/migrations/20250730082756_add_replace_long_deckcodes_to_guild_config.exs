defmodule Backend.Repo.Migrations.AddReplaceLongDeckcodesToGuildConfig do
  use Ecto.Migration

  def change do
    alter table(:guild_config) do
      add :replace_long_deckcodes, :boolean, default: false
    end
  end
end
