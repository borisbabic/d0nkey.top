defmodule Backend.Repo.Migrations.InvitedPlayerUniq do
  use Ecto.Migration

  def change do
    create(
      unique_index(:invited_player, [:tour_stop, :battletag_full, :type, :reason, :official])
    )
  end
end
