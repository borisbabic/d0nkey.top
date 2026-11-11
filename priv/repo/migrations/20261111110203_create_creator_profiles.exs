defmodule Backend.Repo.Migrations.CreateCreatorProfiles do
  use Ecto.Migration

  def change do
    create table(:creator_profiles) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :enabled, :boolean, null: false, default: false
      add :bio, :string, size: 500
      add :links, {:array, :string}, null: false, default: []
      add :show_stream, :boolean, null: false, default: true
      add :show_player_profile, :boolean, null: false, default: false
      add :deck_source, :string, null: false, default: "streamer"
      add :pinned_deck_id, references(:deck, on_delete: :nilify_all)
      add :show_recent_decks, :boolean, null: false, default: true
      add :video_mode, :string, null: false, default: "latest"
      add :pinned_video_id, :string
      add :youtube_channel_id, :string
      add :slug, :string
      add :slug_status, :string
      add :slug_requested_at, :utc_datetime

      timestamps()
    end

    create unique_index(:creator_profiles, [:user_id])

    # many users may request the same slug, but only one can hold it
    create unique_index(:creator_profiles, ["lower(slug)"],
             name: :creator_profiles_active_slug_index,
             where: "slug_status IN ('approved', 'preapproved')"
           )

    create index(:creator_profiles, [:slug_status])
  end
end
