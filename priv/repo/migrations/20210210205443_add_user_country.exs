defmodule Backend.Repo.Migrations.AddUserCountry do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :country_code, :string, null: true
    end
  end
end
