defmodule Backend.Repo.Migrations.AddTwitchLoginDisplay do
  use Ecto.Migration

  def change do
    alter table(:streamer) do
      add :twitch_login, :string, null: true
      add :twitch_display, :string, null: true
    end
  end
end
