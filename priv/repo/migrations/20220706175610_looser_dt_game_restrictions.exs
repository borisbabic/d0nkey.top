defmodule Backend.Repo.Migrations.LooserDtGameRestrictions do
  use Ecto.Migration

  def change do
    alter(table(:dt_games)) do
      modify :opponent_btag, :string, null: true, from: :string
    end
  end
end
