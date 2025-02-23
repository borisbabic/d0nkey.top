defmodule Hearthstone.DeckTracker.IntermediateAggStats do
  @moduledoc """
  Holds hourly aggregated deck and card stats
  """
  use Ecto.Schema
  alias Backend.Hearthstone.Deck

  schema "dt_intermediate_agg_stats" do
    belongs_to :deck, Deck
    field :hour_start, :utc_datetime
    field :day, :date
    field :rank, :string
    field :opponent_class, :string
    field :player_has_coin, :boolean
    field :format, :integer
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
