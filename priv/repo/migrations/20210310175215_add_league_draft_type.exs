defmodule Backend.Repo.Migrations.AddLeagueDraftType do
  use Ecto.Migration

  def change do
    alter table("leagues") do
      add :real_time_draft, :boolean, null: false, default: true
      add :draft_deadline, :utc_datetime, null: true
    end
  end
end
