defmodule Backend.Repo.Migrations.TournamentStreams do
  use Ecto.Migration

  def change do
    create table(:tournament_streams) do
      add :tournament_source, :string
      add :tournament_id, :string
      add :streaming_platform, :string
      add :stream_id, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:tournament_streams, [:user_id])

    create unique_index(:tournament_streams, [
             :tournament_id,
             :tournament_source,
             :stream_id,
             :streaming_platform
           ])
  end
end
