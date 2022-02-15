defmodule Backend.Repo.Migrations.AddIncludeDataToMembership do
  use Ecto.Migration

  def change do
    alter(table(:group_memberships)) do
      add(:include_data, :boolean, default: true)
    end

  end
end
