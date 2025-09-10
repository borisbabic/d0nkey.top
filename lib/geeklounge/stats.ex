defmodule GeekLounge.Hearthstone.Stats do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :win_rate, number()
    field :games_won, integer()
    field :win_streak, integer()
    field :current_rank, String.t()
    field :games_played, integer()
    field :highest_rank, String.t()
  end

  def from_raw_map(map) do
    %__MODULE__{
      win_rate: map["winRate"],
      games_won: map["gamesWon"],
      win_streak: map["winStreak"],
      current_rank: map["currentRank"],
      games_played: map["gamesPlayed"],
      highest_rank: map["highestRank"]
    }
  end
end
