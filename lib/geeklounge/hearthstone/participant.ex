defmodule GeekLounge.Hearthstone.Participant do
  @moduledoc false
  use TypedStruct

  alias GeekLounge.Hearthstone.Deck
  alias GeekLounge.Hearthstone.Player
  alias GeekLounge.Hearthstone.Stats

  typedstruct do
    field :tournament_id, String.t()
    field :player, Player.t()
    field :favorite_class, String.t() | nil
    field :seed, integer() | nil
    field :deck_ids, [String.t()]
    field :decks, [Deck.t()]
    field :stats, Stats.t()
  end

  def from_raw_map(raw) do
    %__MODULE__{
      tournament_id: raw["tournamentId"],
      player: raw["player"] |> Player.from_raw_map(),
      favorite_class: raw["favoriteClass"],
      deck_ids: raw["deckIds"],
      decks: raw["decks"] |> Enum.map(&Deck.from_raw_map/1),
      stats: raw["stats"] |> Stats.from_raw_map(),
      seed: raw["seed"]
    }
  end
end
