defmodule Backend.HSReplay.Streaming do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :deck, [integer]
    field :hero, integer
    field :format, integer
    field :rank, integer
    field :legend_rank, integer
    field :game_type, integer
    field :twitch, Backend.HSReplay.Streaming.Twitch.t()
  end

  def deckcode(%{deck: d, hero: h, format: f}), do: Backend.Hearthstone.Deck.deckcode(d, h, f)

  def from_raw_map(map = %{"legend_rank" => lr}) do
    %__MODULE__{
      deck: map["deck"],
      hero: map["hero"],
      format: map["format"],
      rank: map["rank"],
      legend_rank: lr,
      game_type: map["game_type"],
      twitch: Backend.HSReplay.Streaming.Twitch.from_raw_map(map["twitch"])
    }
  end
end

defmodule Backend.HSReplay.Streaming.Twitch do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :id, String.t()
    field :login, String.t()
    field :display_name, String.t()
  end

  def from_raw_map(map = %{"display_name" => dn}) do
    %__MODULE__{
      id: map["id"],
      login: map["login"],
      display_name: dn
    }
  end
end
