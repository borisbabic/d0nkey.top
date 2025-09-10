defmodule GeekLounge.Hearthstone.Deck do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :id, String.t()
    field :name, String.t()
    field :deck_string, String.t()
    field :player_class, String.t()

    # Not gonna bother with these
    # field :cards
    # field :sideboard_cards

    field :dust_cost, integer()
    field :format, String.t()
    field :last_modified, NaiveDateTime.t() | nil
    field :games_played, integer()
    field :wins, integer()
    field :win_rate, number()
    field :hidden?, boolean()
    field :active?, boolean()
    field :total_cards, integer()
    field :average_mana_cost, number()
  end

  def from_raw_map(map) do
    last_modified =
      case NaiveDateTime.from_iso8601(map["lastModified"]) do
        {:ok, lm} -> lm
        _ -> nil
      end

    %__MODULE__{
      id: map["id"],
      name: map["name"],
      deck_string: map["deckString"],
      player_class: map["playerClass"],
      dust_cost: map["dustCost"],
      format: map["format"],
      last_modified: last_modified,
      games_played: map["gamesPlayed"],
      wins: map["wins"],
      win_rate: map["winRate"],
      hidden?: map["isHidden"],
      active?: map["isActive"],
      total_cards: map["totalCards"],
      average_mana_cost: map["averageManaCost"]
    }
  end
end
