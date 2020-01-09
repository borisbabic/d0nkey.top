defmodule Backend.Repo.Migrations.AddInvitedPlayerInfo do
  use Ecto.Migration

  def change do
    alter table(:invited_player) do
      add :upstream_time, :utc_datetime, null: true
      add :tournament_slug, :string, null: true
      add :tournament_id, :string, null: true
    end
  end
end
