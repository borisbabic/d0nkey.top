defmodule Hearthstone.DeckTracker.AggregationLog do
  @moduledoc "Holds a log aggregations including what was logged"
  use Ecto.Schema

  schema "logs_dt_aggregation" do
    field :formats, {:array, :integer}
    field :ranks, {:array, :string}
    field :periods, {:array, :string}
    timestamps(updated_at: false)
  end
end
