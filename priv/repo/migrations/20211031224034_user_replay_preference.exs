defmodule Backend.Repo.Migrations.UserReplayPreference do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :replay_preference, :integer, default: 8
    end
  end
end
