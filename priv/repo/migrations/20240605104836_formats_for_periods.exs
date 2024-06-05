defmodule Backend.Repo.Migrations.FormatsForPeriods do
  use Ecto.Migration

  def change do
    alter table(:dt_periods) do
      add :formats, {:array, :integer}, default: [1, 2, 3, 4], null: false
    end
  end
end
