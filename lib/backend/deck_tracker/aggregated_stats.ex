defmodule Hearthstone.DeckTracker.AggregatedStats do
  @moduledoc """
  Holds aggregated deck and card stats
  """
  use Ecto.Schema
  alias Backend.Hearthstone.Deck

  schema "dt_aggregated_stats" do
    belongs_to :deck, Deck
    field :period, :string, primary_key: true
    field :rank, :string, primary_key: true
    field :opponent_class, :string, primary_key: true
    field :archetype, :string, primary_key: true
    field :format, :integer, primary_key: true
    field :winrate, :float
    field :wins, :decimal
    field :losses, :decimal
    field :total, :decimal
    field :card_stats, {:array, :map}
  end
end
