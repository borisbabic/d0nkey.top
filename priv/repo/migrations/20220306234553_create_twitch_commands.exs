defmodule Backend.Repo.Migrations.CreateTwitchCommands do
  use Ecto.Migration

  def change do
    create table(:twitch_commands) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :type, :string
      add :name, :string
      add :enabled, :boolean, default: false, null: false
      add :message, :text
      add :response, :text
      add :message_regex, :boolean, default: false, null: false
      add :message_regex_flags, :string
      add :sender, :string
      add :sender_regex, :boolean, default: false, null: false
      add :sender_regex_flags, :string
      add :random_chance, :float

      timestamps()
    end

    create index(:twitch_commands, [:user_id])
  end
end
