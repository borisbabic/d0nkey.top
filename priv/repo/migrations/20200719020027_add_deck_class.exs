defmodule Backend.Repo.Migrations.AddDeckClass do
  use Ecto.Migration

  def change do
    alter table(:deck) do
      add :class, :string
    end
  end
end
