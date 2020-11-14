defmodule Backend.Repo.Migrations.RenameTwitchLoginDisplay do
  use Ecto.Migration

  def change do
    rename table(:streamer), :twitch_login, to: :hsreplay_twitch_login
    rename table(:streamer), :twitch_display, to: :hsreplay_twitch_display
  end
end
