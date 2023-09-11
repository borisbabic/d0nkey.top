defmodule Hearthstone.DeckTracker.PeriodUpdate do
  @moduledoc """
  When a period was updated for aggregate stats
  Used to prune old updates
  Maybe provide historical data?
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "dt_period_update" do
    belongs_to :period, Period
    field :do_not_delete, :boolean, default: false
    timestamps()
  end

  def changeset(pd, attrs) do
    pd
    |> cast(attrs, [:period_id, :do_not_delete])
    |> validate_required([:period_id])
  end
end
