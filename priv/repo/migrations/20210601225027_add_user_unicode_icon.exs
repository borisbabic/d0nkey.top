defmodule Backend.Repo.Migrations.AddUserUnicodeIcon do
  use Ecto.Migration

  def change do
    alter(table(:users)) do
      add :unicode_icon, :string, default: nil
    end
  end
end
