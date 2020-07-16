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

  def is_standard(%{format: 1}), do: true
  def is_standard(_), do: false

  def is_wild(%{format: 2}), do: true
  def is_wild(_), do: false

  def deckcode(%{deck: d, hero: h, format: f}) do
    cards =
      d
      |> Enum.frequencies()
      |> Enum.group_by(fn {_card, freq} -> freq end, fn {card, _freq} -> card end)

    ([0, 1, f, 1, h] ++
       deckcode_part(cards[1]) ++
       deckcode_part(cards[2]) ++
       [0])
    |> Enum.into(<<>>, fn i -> Varint.LEB128.encode(i) end)
    |> Base.encode64()
  end

  defp deckcode_part(nil), do: []
  defp deckcode_part(cards), do: [Enum.count(cards) | cards |> Enum.sort()]

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
