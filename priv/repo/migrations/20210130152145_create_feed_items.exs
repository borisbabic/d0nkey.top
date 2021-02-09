defmodule Backend.Repo.Migrations.CreateFeedItems do
  use Ecto.Migration

  def change do
    create table(:feed_items) do
      add :decay_rate, :float
      add :cumulative_decay, :float
      add :points, :float
      add :decayed_points, :float
      add :value, :string
      add :type, :string

      timestamps()
    end

    create(unique_index(:feed_items, [:type, :value], name: :feed_items_type_value_index))
  end
end
