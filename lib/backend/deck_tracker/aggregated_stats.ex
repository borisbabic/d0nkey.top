defmodule Hearthstone.DeckTracker.AggregatedStats do
  @moduledoc """
  Holds aggregated deck and card stats
  """
  use Ecto.Schema
  alias Backend.Hearthstone.Deck

  schema "test_dt_aggregated_stats" do
    belongs_to :deck, Deck
    field :period, :string, primary_key: true
    field :rank, :string, primary_key: true
    field :opponent_class, :string, primary_key: true
    field :archetype, :string, primary_key: true
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
