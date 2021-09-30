defmodule Backend.Repo.Migrations.CreateHsKeywords do
  use Ecto.Migration

  def change do
    create table(:hs_keywords) do
      add :name, :string
      add :slug, :string
      add :game_modes, {:array, :integer}
      add :ref_text, :string
      add :text, :string

      timestamps()
    end
  end
end
