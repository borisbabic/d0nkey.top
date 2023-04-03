defmodule Backend.Repo.Migrations.DeckSheet do
  use Ecto.Migration
  alias Backend.DeckSheet.DeckSheet

  def change do
    create table(:deck_sheets) do
      add :name, :string, null: false
      add :owner_id, references(:users, on_delete: :delete_all), null: false
      add :group_id, references(:groups, on_delete: :nilify_all), null: true
      add :group_role, :string, default: "editor"
      add :public_role, :string, default: "nothing"
      add :extra_columns, {:array, :string}, null: false

      timestamps()
    end
  end
end
