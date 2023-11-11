defmodule Backend.Repo.Migrations.CreateFormats do
  use Ecto.Migration

  def change do
    create table(:formats) do
      add :value, :integer, default: nil, null: true
      add :display, :string
      add :order_priority, :integer, default: 0
      add :default, :boolean, default: false, null: false
      add :include_in_personal_filters, :boolean, default: false, null: false
      add :include_in_deck_filters, :boolean, default: false, null: false
      add :auto_aggregate, :boolean, default: false, null: false

      timestamps()
    end
  end
end
