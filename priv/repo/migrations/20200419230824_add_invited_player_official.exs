defmodule Backend.Repo.Migrations.AddInvitedPlayerOfficial do
  use Ecto.Migration

  def change do
    alter table(:invited_player) do
      add :official, :boolean, null: false, default: true
    end
  end
end
