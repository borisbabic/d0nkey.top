defmodule Backend.Repo.Migrations.AddUserAdminRoles do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :admin_roles, {:array, :string}
    end
  end
end
