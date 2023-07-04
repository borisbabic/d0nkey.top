defmodule Backend.Repo.Migrations.TextCardTestFlavorText do
  use Ecto.Migration

  def change do
    alter table(:hs_cards) do
      modify :text, :text
      modify :flavor_text, :text
    end
  end
end
