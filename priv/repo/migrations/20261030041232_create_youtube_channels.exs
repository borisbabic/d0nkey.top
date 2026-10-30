defmodule Backend.Repo.Migrations.CreateYoutubeChannels do
  use Ecto.Migration

  def change do
    create table(:youtube_channels) do
      add :channel_id, :string, null: false
      add :title, :string
      add :handle, :string
      add :thumbnail_url, :string, size: 1024
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:youtube_channels, [:channel_id])
    create index(:youtube_channels, [:user_id])
  end
end
