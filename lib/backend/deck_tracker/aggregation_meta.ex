defmodule Hearthstone.DeckTracker.AggregationMeta do
  @moduledoc "Hold the counts from the last aggregation to be smart about min count for decks"
  use Ecto.Schema

  @primary_key false
  schema "dt_aggregation_meta" do
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
    field :overall_winrate, :float
    timestamps(updated_at: false)
  end

  @supported_options [12_800, 6400, 3200, 1600, 800, 400, 200]

  def choose_count(%__MODULE__{} = ac, min_count, fallback \\ 200, options \\ @supported_options) do
    Enum.find(@supported_options, fallback, fn c ->
      c in options
      count(ac, c) >= min_count
    end)
  end

  @doc "Returns 0 if sample is not supported"
  def count(%__MODULE__{} = ac, sample) when sample in @supported_options do
    key = String.to_atom("count_#{sample}")
    Map.get(ac, key, 0)
  end

  def count(_, _), do: 0
end
