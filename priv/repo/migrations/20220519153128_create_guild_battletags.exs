defmodule Backend.Repo.Migrations.CreateGuildBattletags do
  use Ecto.Migration

  def change do
    create table(:guild_battletags, primary_key: false) do
      add :guild_id, :bigint, primary_key: true
      add :channel_id, :bigint, null: false
      add :last_message_id, :bigint, null: true
      add :battletags, {:array, :string}, default: []

      timestamps()
    end
  end
end
