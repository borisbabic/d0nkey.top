defmodule Backend.Repo.Migrations.AddYoutubeToStreamer do
  use Ecto.Migration

  def change do
    alter table(:streamer) do
      modify :twitch_id, :integer, null: true, from: {:integer, null: false}
      add :youtube_channel_id, :string
      add :youtube_display, :string
      add :youtube_handle, :string
    end

    create unique_index(:streamer, [:youtube_channel_id])

    create constraint(:streamer, :streamer_has_channel,
             check: "twitch_id IS NOT NULL OR youtube_channel_id IS NOT NULL"
           )
  end
end
