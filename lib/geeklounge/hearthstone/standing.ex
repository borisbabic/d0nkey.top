defmodule GeekLounge.Hearthstone.Standing do
  @moduledoc false
  use TypedStruct
  alias GeekLounge.Hearthstone.Player

  typedstruct do
    field :player, Player.t()
    field :wins, integer()
    field :losses, integer()
    field :match_wins, integer()
    field :match_losses, integer()
  end

  def from_raw_map(map) do
    %__MODULE__{
      player: Player.from_raw_map(map["player"]),
      match_wins: Map.get(map, "match_wins", 0),
      match_losses: Map.get(map, "match_losses", 0),
      wins: Map.get(map, "wins", 0),
      losses: Map.get(map, "losses", 0)
    }
  end
end
