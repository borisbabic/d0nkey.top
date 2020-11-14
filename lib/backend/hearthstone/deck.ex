defmodule Backend.Hearthstone.Deck do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  @required [:cards, :hero, :format, :deckcode, :class]
  @optional [:hsreplay_archetype]
  schema "deck" do
    field :cards, {:array, :integer}
    field :deckcode, :string
    field :format, :integer
    field :hero, :integer
    field :class, :string
    field :hsreplay_archetype, :integer, default: nil
    timestamps()
  end

  @doc false
  def changeset(c, attrs = %{deckcode: d}) when not is_nil(d) do
    c
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end

  @doc false
  def changeset(c, a), do: changeset(c, a |> Map.put(:deckcode, deckcode(a)))

  def deckcode(%{cards: c, hero: h, format: f}), do: deckcode(c, h, f)

  @doc """
  Calculate the deckcode from deck parts.
  Doesn't support decks with more than 2 copies of a card
  """
  @spec deckcode([integer], integer, integer) :: String.t()
  def deckcode(cards, hero, format) do
    cards =
      cards
      |> Enum.frequencies()
      |> Enum.group_by(fn {_card, freq} -> freq end, fn {card, _freq} -> card end)

    ([0, 1, format, 1, hero] ++
       deckcode_part(cards[1]) ++
       deckcode_part(cards[2]) ++
       [0])
    |> Enum.into(<<>>, fn i -> Varint.LEB128.encode(i) end)
    |> Base.encode64()
  end

  defp deckcode_part(nil), do: [0]
  defp deckcode_part(cards), do: [Enum.count(cards) | cards |> Enum.sort()]

  def class_name("DEMONHUNTER"), do: "Demon Hunter"
  def class_name(c), do: c |> Recase.to_title()
end
