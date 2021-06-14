defmodule Backend.Repo.Migrations.CreateApiUsers do
  use Ecto.Migration

  def change do
    create table(:api_users) do
      add :username, :string
      add :password, :string

      timestamps()
    end

    create unique_index(:api_users, [:username])
  end
end
