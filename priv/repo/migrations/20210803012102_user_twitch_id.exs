defmodule Backend.Repo.Migrations.UserTwitchId do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :twitch_id, :string
    end

    create(unique_index(:users, [:twitch_id], name: :user_twitch_id_unique))
  end
end
