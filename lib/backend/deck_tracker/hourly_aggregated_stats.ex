defmodule Hearthstone.DeckTracker.HourlyAggregatedStats do
  @moduledoc """
  Holds hourly aggregated deck and card stats
  """
  use Ecto.Schema
  alias Backend.Hearthstone.Deck

  schema "dt_hourly_aggregated_stats" do
    belongs_to :deck, Deck, primary_key: true
    field :hour_start, :utc_datetime, primary_key: true
    field :rank, :string, primary_key: true
    field :opponent_class, :string, primary_key: true
    field :archetype, :string, primary_key: true
    field :format, :integer, primary_key: true
    field :winrate, :float
    field :wins, :decimal
    field :losses, :decimal
    field :total, :decimal
    field :turns, :integer
    field :total_turns, :integer
    field :turns_game_count, :integer
    field :duration, :integer
    field :total_duration, :integer
    field :duration_game_count, :integer
    field :climbing_speed, :float
    field :card_stats, {:array, :map}
  end
end
