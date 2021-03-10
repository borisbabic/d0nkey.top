defmodule Backend.Repo.Migrations.AddLeagueDraftInfo do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table("leagues") do
      add :time_per_pick, :integer, null: false, default: 0
      add :last_pick_at, :utc_datetime, null: true
      add :pick_order, {:array, :integer}, default: []
      add :current_pick_number, :integer, null: false, default: 0
    end
  end
end
