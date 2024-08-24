defmodule Backend.Repo.Migrations.InitSetReleaseDate do
  use Ecto.Migration

  def up do
    Backend.Hearthstone.init_card_set_release_date()
  end

  def down do
  end
end
