defmodule Hearthstone.DeckTracker.AggregationLog do
  @moduledoc "Holds a log aggregations including what was logged"
  use Ecto.Schema

  @primary_key false
  schema "logs_dt_aggregation" do
    field :formats, {:array, :integer}, default: []
    field :ranks, {:array, :string}, default: []
    field :periods, {:array, :string}, default: []
    field :regions, {:array, :string}, default: []
    timestamps(updated_at: false)
  end

  def empty() do
    %__MODULE__{
      formats: [],
      ranks: [],
      periods: [],
      regions: []
    }
  end
end
