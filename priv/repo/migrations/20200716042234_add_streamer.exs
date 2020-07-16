defmodule Backend.Repo.Migrations.AddStreamer do
  use Ecto.Migration

  def change do
    create table(:streamer) do
      add :twitch_login, :string, null: false
      add :twitch_display, :string, null: false
      add :twitch_id, :integer, null: false
      timestamps()
    end

    create(unique_index(:streamer, [:twitch_id], name: :steamer_twitch_id_unique_index))
  end
end
