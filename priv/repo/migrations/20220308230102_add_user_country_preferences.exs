defmodule Backend.Repo.Migrations.AddUserCountryPreferences do
  use Ecto.Migration

  def change do
    alter(table(:users)) do
      add :cross_out_country, :boolean, default: false
      add :show_region, :boolean, default: false
    end

  end
end
