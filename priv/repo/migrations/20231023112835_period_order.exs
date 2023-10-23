defmodule Backend.Repo.Migrations.PeriodOrder do
  use Ecto.Migration

  def change do
    alter table(:dt_periods) do
      add(:order_priority, :integer, null: true, default: 0)
    end
  end
end
