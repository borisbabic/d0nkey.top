defmodule Backend.Repo.Migrations.DtGamesReplayUrl do
  use Ecto.Migration

  def change do
    alter(table(:dt_games)) do
      add(:replay_url, :string, default: nil)
    end

  end
end
