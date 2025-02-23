defmodule Hearthstone.DeckTracker.HourlyAggregationLog do
  @moduledoc """
  Log of hours that have been aggregated and with what
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "logs_dt_hourly_aggregation" do
    field :hour_start, :utc_datetime
    field :day, :date
    field :formats, {:array, :integer}
    field :ranks, {:array, :string}
    field :regions, {:array, :string}

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(agg_log, attrs) do
    agg_log
    |> cast(attrs, [:hour_star, :formats, :ranks, :regions, :day])
    |> validate_required([:formats, :ranks, :regions])
  end
end
