defmodule Backend.Repo.Migrations.CreateRanks do
  use Ecto.Migration

  def change do
    create table(:ranks) do
      add :slug, :string
      add :display, :string
      add :min_rank, :integer, default: 0
      add :max_rank, :integer, null: true
      add :min_legend_rank, :integer, default: 0
      add :max_legend_rank, :integer, null: true
      add :include_in_personal_filters, :boolean, default: false, null: false
      add :include_in_deck_filters, :boolean, default: false, null: false
      add :auto_aggregate, :boolean, default: false, null: false
      add :order_priority, :integer, default: 0
      add :default, :boolean, default: false

      timestamps()
    end
  end
end
