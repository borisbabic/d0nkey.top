defmodule Hearthstone.DeckTracker.PartitionedAggregatedStats do
  @moduledoc """
  Holds aggregated deck and card stats partitioned by period
  """
  use Ecto.Schema
  alias Backend.Hearthstone.Deck

  schema "dt_partitioned_aggregated_stats" do
    belongs_to :deck, Deck
    field :rank, :string, primary_key: true
    field :opponent_class, :string, primary_key: true
    field :archetype, :string, default: nil, primary_key: true
    field :format, :integer, primary_key: true
    field :winrate, :float
    field :wins, :integer
    field :losses, :integer
    field :total, :integer
    field :turns, :float
    field :duration, :float
    field :climbing_speed, :float
    field :player_has_coin, :boolean
    field :card_stats, {:array, :map}
  end
end
