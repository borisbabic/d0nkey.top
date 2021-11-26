defmodule Backend.Repo.Migrations.GamePublic do
  use Ecto.Migration

  def change do
    alter table(:dt_games) do
      add :public, :boolean, default: false
    end
  end
end
