defmodule GeekLounge.Hearthstone.Match do
  @moduledoc false

  use TypedStruct
  alias GeekLounge.Hearthstone.MatchPlayer

  typedstruct do
    field :id, String.t()
    field :match_number, integer()
    field :round, integer()
    field :live?, boolean()
    field :winner_id, String.t()
    field :player1, MatchPlayer.t() | nil
    field :player2, MatchPlayer.t() | nil
  end

  def from_raw_map(map) do
    %__MODULE__{
      id: map["id"],
      match_number: map["matchNumber"],
      round: map["round"],
      live?: map["isLive"],
      player1: map["player1"] |> MatchPlayer.from_raw_map(),
      player2: map["player2"] |> MatchPlayer.from_raw_map()
    }
  end
end

defmodule GeekLounge.Hearthstone.MatchPlayer do
  @moduledoc false
  use TypedStruct

  alias GeekLounge.Hearthstone.Player

  typedstruct do
    field :player, Player.t()
    field :score, integer()
    field :winner, boolean()
  end

  def from_raw_map(nil), do: nil

  def from_raw_map(map) when is_map(map) do
    %__MODULE__{
      player: Player.from_raw_map(map["player"]),
      score: map["score"],
      winner: map["winner"]
    }
  end
end
