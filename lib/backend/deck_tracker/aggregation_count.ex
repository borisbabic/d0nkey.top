defmodule Hearthstone.DeckTracker.AggregationCount do
  @moduledoc "Hold the counts from the last aggregation to be smart about min count for decks"
  use Ecto.Schema

  @primary_key false
  schema "dt_aggregation_counts" do
    field :format, :integer
    field :rank, :string
    field :period, :string
    field :count, :integer
    field :total_sum, :integer
    field :count_200, :integer
    field :count_400, :integer
    field :count_800, :integer
    field :count_1600, :integer
    field :count_3200, :integer
    field :count_6400, :integer
    field :count_12800, :integer
    timestamps(updated_at: false)
  end
end
