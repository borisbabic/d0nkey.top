defmodule Backend.Hearthstone.Deck do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  @required [:cards, :hero, :format, :deckcode]
  @optional [:hsreplay_archetype, :class]
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

  def remove_comments(deckcode_string) do
    deckcode_string
    |> String.split("\n")
    |> Enum.find(fn l -> l |> String.at(0) != "#" end)
  end

  def decode(deckcode) do
    [0, 1, format, 1, hero | cards_parts] =
      deckcode
      |> remove_comments()
      |> Base.decode64()
      |> case do
        {:ok, decoded} -> decoded
        _ -> raise "Couldn't decode presumed base64 string"
      end
      |> :binary.bin_to_list()
      |> chunk_parts()
      |> Enum.map(&Varint.LEB128.decode/1)

    cards = decode_cards_parts(cards_parts, 1, [])

    attrs = %{format: format, hero: hero, cards: cards, deckcode: deckcode}

    %__MODULE__{}
    |> changeset(attrs)
  end

  defp decode_cards_parts([0], _, cards), do: cards

  defp decode_cards_parts([to_take | parts], num_copies, acc_cards) do
    cards = parts |> Enum.take(to_take)

    decode_cards_parts(
      parts |> Enum.drop(to_take),
      num_copies + 1,
      acc_cards ++ for(c <- cards, _ <- 1..num_copies, do: c)
    )
  end

  defp decode_cards_parts(_, _, cards), do: cards

  defp chunk_parts(parts) do
    chunk_fun = fn element, acc ->
      if element < 128 do
        {:cont, [element | acc] |> Enum.reverse() |> :binary.list_to_bin(), []}
      else
        {:cont, [element | acc]}
      end
    end

    after_fun = fn
      [] -> {:cont, []}
      acc -> {:cont, acc |> Enum.reverse() |> :binary.list_to_bin(), []}
    end

    parts
    |> Enum.chunk_while([], chunk_fun, after_fun)
  end
end
