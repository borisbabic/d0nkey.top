defmodule Hearthstone.DeckTracker.AggregatedMatchups do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "dt_aggregated_matchups" do
    field(:matchups_version, :integer, default: 1)
    field(:matchups, Ecto.ErlangTerm)
    field(:period, :binary)
    field(:rank, :binary)
    field(:format, :integer)
    # field(:archetypes, {:array, :string})
    timestamps()
  end

  def changeset(aggregated_matchups, attrs) do
    aggregated_matchups
    |> cast(attrs, [
      :matchups_version,
      :matchups,
      :period,
      :rank,
      :format
    ])
  end
end
