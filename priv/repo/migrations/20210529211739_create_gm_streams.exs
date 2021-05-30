defmodule Backend.Repo.Migrations.CreateGmStreams do
  use Ecto.Migration

  def change do
    create table(:gm_streams) do
      add :stream_id, :string
      add :stream, :string

      timestamps()
    end
  end
end
