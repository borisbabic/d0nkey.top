defmodule Backend.Repo.Migrations.InitCanonicalDeckcodeIdToCard do
  use Ecto.Migration

  def up do
    Backend.Hearthstone.set_referent_card_ids()
  end

  def down do
  end
end
