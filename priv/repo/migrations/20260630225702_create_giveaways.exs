defmodule Backend.Repo.Migrations.CreateGiveaways do
  use Ecto.Migration

  def change do
    create table(:giveaways) do
      add :name, :string
      add :config, :map, default: nil
      add :description, :text, default: nil
      add :deadline, :naive_datetime
      add :number_of_winners, :integer, default: 1
      add :creator_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:giveaways, [:creator_id])
  end
end
