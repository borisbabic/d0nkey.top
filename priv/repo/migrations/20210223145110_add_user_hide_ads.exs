defmodule Backend.Repo.Migrations.AddUserHideAds do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:hide_ads, :boolean, default: false)
    end
  end
end
