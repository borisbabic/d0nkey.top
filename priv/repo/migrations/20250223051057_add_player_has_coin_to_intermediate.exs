defmodule Backend.Repo.Migrations.AddPlayerHasCoinToIntermediate do
  use Ecto.Migration

  def change do
    alter table(:dt_intermediate_agg_stats) do
      add :player_has_coin, :boolean, null: true
    end
  end
end
