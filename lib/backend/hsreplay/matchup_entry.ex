defmodule Backend.HSReplay.MatchupEntry do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :total_games, integer
    field :win_rate, float
  end

  def from_raw_map(%{"total_games" => tg, "win_rate" => wr}) do
    %__MODULE__{
      total_games: tg,
      win_rate: wr
    }
  end
end
