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

  @spec deckcode(__MODULE__) :: String.t()
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

  @spec class_name([integer] | nil) :: [integer]
  defp deckcode_part(nil), do: [0]
  defp deckcode_part(cards), do: [Enum.count(cards) | cards |> Enum.sort()]

  @spec class_name(String.t()) :: String.t()
  def class_name("DEMONHUNTER"), do: "Demon Hunter"
  def class_name(c), do: c |> Recase.to_title()

  @spec remove_comments(String.t()) :: String.t()
  def remove_comments(deckcode_string) do
    deckcode_string
    |> String.split(["\n", "\r\n"])
    |> Enum.find(fn l -> l |> String.at(0) != "#" end)
  end

  @spec extract_name(String.t()) :: String.t()
  def extract_name(deckcode) do
    ~r/^### (.*)/
    |> Regex.run(deckcode)
    |> case do
      nil -> nil
      [_, name] -> name |> String.trim()
    end
  end

  @spec decode!(String.t()) :: __MODULE__
  def decode!(deckcode), do: decode(deckcode) |> Util.bangify()

  @doc """
  Decode a deckcode into a Deck struct
  ## Example
  iex> Backend.Hearthstone.Deck.decode("blabla")
  {:error, "Couldn't decode deckstring"}
  iex> {:ok, deck} = Backend.Hearthstone.Deck.decode("AAECAR8BugMAAA=="); deck.deckcode
  "AAECAR8BugMAAA=="
  """
  @spec decode(String.t()) :: {:ok, __MODULE__} | {:error, String.t() | any}
  def decode(deckcode) do
    with no_comments <- remove_comments(deckcode),
         {:ok, decoded} <- Base.decode64(no_comments),
         list <- :binary.bin_to_list(decoded),
         chunked <- chunk_parts(list),
         [0, 1, format, 1, hero | card_parts] <- Enum.map(chunked, &Varint.LEB128.decode/1),
         cards <- decode_cards_parts(card_parts, 1, []) do
      {:ok, %__MODULE__{format: format, hero: hero, cards: cards, deckcode: no_comments}}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Couldn't decode deckstring"}
    end
  end

  @spec decode_cards_parts([integer], integer, [integer]) :: [integer]
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

  @spec chunk_parts([byte()]) :: [[byte()]]
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

  @spec format_name(integer) :: String.t()
  def format_name(1), do: "Wild"
  def format_name(2), do: "Standard"
  def format_name(9001), do: "Duels"

  @spec get_basic_hero(String.t()) :: integer
  def get_basic_hero(class) do
    class
    |> normalize_class_name()
    |> case do
      "DEMONHUNTER" -> 56_550
      "DRUID" -> 274
      "HUNTER" -> 31
      "MAGE" -> 637
      "PALADIN" -> 671
      "PRIEST" -> 813
      "ROGUE" -> 930
      "SHAMAN" -> 1_066
      "WARLOCK" -> 893
      "WARRIOR" -> 7
      # lich king
      _ -> 42_458
    end
  end

  """
  Converts it to single word upper case

  ## Example
  iex> Backend.Hearhtsotne.normalize_class_name("Demon HuNter")
  "DEMONHUNTER"

  """

  @spec normalize_class_name(String.t()) :: String.t()
  def normalize_class_name(class),
    do:
      class
      |> String.upcase()
      |> String.replace(~r/\w/, "")

  @spec shorten_codes([String.t()]) :: [String.t()]
  def shorten_codes(codes) do
    codes
    |> Enum.map(&decode/1)
    |> Enum.filter(&(:ok == elem(&1, 0)))
    |> Enum.map(&(&1 |> elem(1) |> deckcode()))
  end

  @spec shorten([String.t()]) :: [String.t()]
  def shorten(deckcodes) when is_list(deckcodes) do
    deckcodes
    |> Enum.map(&shorten/1)
    |> Enum.flat_map(fn
      {:ok, code} -> [code]
      _ -> []
    end)
  end

  @spec shorten(String.t()) :: String.t()
  def shorten(deckcodes) when is_binary(deckcodes) do
    with {:ok, deck} <- decode(deckcodes),
         deckcode when is_binary(deckcode) <- deckcode(deck) do
      {:ok, deckcode}
    else
      ret = {:error, _} -> ret
      _ -> {:error, "Couldn't decode deckcode"}
    end
  end
end
