defmodule Backend.Repo.Migrations.CreateDeveloperApiKeys do
  use Ecto.Migration

  def change do
    create table(:developer_api_keys) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token_prefix, :string, null: false
      add :token_digest, :binary, null: false
      add :revoked_at, :naive_datetime

      timestamps()
    end

    create unique_index(:developer_api_keys, [:token_prefix])

    create unique_index(:developer_api_keys, [:user_id],
             where: "revoked_at IS NULL",
             name: :developer_api_keys_one_active_per_user
           )
  end
end
