defmodule Backend.Repo.Migrations.AddInvitedPlayer do
  use Ecto.Migration

  def change do
    create table(:invited_player) do
      add :battletag_full, :string, null: false
      add :tour_stop, :string, null: false
      add :type, :string, null: true
      add :reason, :string, null: true

      timestamps()
    end
  end
end
