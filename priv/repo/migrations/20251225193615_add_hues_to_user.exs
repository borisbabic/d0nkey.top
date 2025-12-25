defmodule Backend.Repo.Migrations.AddHuesToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :positive_hue, :integer, default: nil
      add :negative_hue, :integer, default: nil
    end
  end
end
