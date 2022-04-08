defmodule Backend.Repo.Migrations.HsreplayDeckMap do
  use Ecto.Migration

  def change do
    create table(:hsr_deck_map) do
      add :hsr_deck_id, :string
      add :deck_id, references(:deck, on_delete: :nothing)
    end

    create(unique_index(:hsr_deck_map, [:hsr_deck_id]))

  end
end
