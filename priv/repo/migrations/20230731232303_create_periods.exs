defmodule Backend.Repo.Migrations.CreatePeriods do
  use Ecto.Migration

  def change do
    create table(:dt_periods) do
      add :slug, :string
      add :display, :string
      add :type, :string
      add :period_start, :naive_datetime
      add :period_end, :naive_datetime
      add :hours_ago, :integer
      add :include_in_personal_filters, :boolean, default: false, null: false
      add :include_in_deck_filters, :boolean, default: false, null: false
      add :auto_aggregate, :boolean, default: false, null: false

      timestamps()
    end
  end
end
