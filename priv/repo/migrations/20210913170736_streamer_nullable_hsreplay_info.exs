defmodule Backend.Repo.Migrations.StreamerNullableHsreplayInfo do
  use Ecto.Migration

  def change do
    alter table(:streamer) do
      modify(:hsreplay_twitch_login, :string, null: true, from: :string)
      modify(:hsreplay_twitch_display, :string, null: true, from: :string)
    end
  end
end
