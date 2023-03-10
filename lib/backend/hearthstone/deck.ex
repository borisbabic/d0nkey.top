defmodule Backend.Hearthstone.Deck do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Hearthstone.Card.RuneCost
  alias Backend.Hearthstone
  alias Backend.HearthstoneJson

  @required [:cards, :hero, :format, :deckcode]
  @optional [:hsreplay_archetype, :class, :archetype]
  @type t :: %__MODULE__{}
  schema "deck" do
    field :cards, {:array, :integer}
    field :deckcode, :string
    field :format, :integer
    field :hero, :integer
    field :class, :string
    field :archetype, Ecto.Atom, default: nil
    field :hsreplay_archetype, :integer, default: nil
    timestamps()
  end

  @doc false
  def changeset(c, attrs = %{hsreplay_archetype: %{id: id}}) do
    changeset(c, attrs |> Map.put(:hsreplay_archetype, id))
  end

  @doc false
  def changeset(c, attrs = %{deckcode: _}) do
    c
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end

  def changeset(c, a) do
    attrs = Map.put(a, :deckcode, deckcode(a))
    changeset(c, attrs)
  end

  @spec deckcode(t()) :: String.t()
  def deckcode(%{cards: c, hero: h, format: f}), do: deckcode(c, h, f)

  @doc """
  Calculate the deckcode from deck parts.
  Doesn't support decks with more than 2 copies of a card
  """
  @spec deckcode([integer], integer, integer) :: String.t()
  def deckcode(c, hero, format) do
    cards =
      c
      |> canonicalize_cards()
      |> Enum.frequencies()
      |> Enum.group_by(fn {_card, freq} -> freq end, fn {card, _freq} -> card end)

    ([0, 1, format, 1, get_canonical_hero(hero, c)] ++
       deckcode_part(cards[1]) ++
       deckcode_part(cards[2]) ++
       [0])
    |> Enum.into(<<>>, fn i -> Varint.LEB128.encode(i) end)
    |> Base.encode64()
  end

  defp canonicalize_cards(cards), do: Enum.map(cards, &HearthstoneJson.canonical_id/1)

  @spec deckcode_part([integer] | nil) :: [integer]
  defp deckcode_part(nil), do: [0]
  defp deckcode_part(cards), do: [Enum.count(cards) | cards |> Enum.sort()]

  @spec class_name(String.t() | Deck.t()) :: String.t()
  def class_name(%__MODULE__{class: class}) when is_binary(class),
    do: class |> String.upcase() |> class_name()

  def class_name(%__MODULE__{hero: h}) do
    case Hearthstone.class(h) do
      nil -> ""
      class -> class |> String.upcase() |> class_name()
    end
  end

  def class_name("DEATHKNIGHT"), do: "Death Knight"
  def class_name("DEMONHUNTER"), do: "Demon Hunter"
  def class_name(c) when is_binary(c), do: c |> Recase.to_title()
  def class_name(other), do: other

  def name(%{archetype: a}) when not is_nil(a), do: a

  def name(deck) do
    with nil <- Backend.Hearthstone.DeckArchetyper.archetype(deck) do
      class_name(deck)
    end
  end

  @spec remove_comments(String.t()) :: String.t()
  def remove_comments(deckcode_string) do
    deckcode_string
    |> String.split(["\n", "\r\n"])
    |> Enum.find(fn l -> String.trim(l) != "" && l |> String.at(0) != "#" end)
    |> Kernel.||("")
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

  @spec valid?(String.t() | any()) :: boolean
  def valid?(code) when is_binary(code), do: :ok == code |> decode() |> elem(0)
  def valid?(_), do: false

  @spec decode!(String.t()) :: t()
  def decode!(deckcode), do: deckcode |> decode() |> Util.bangify()

  # todo make 任务贼：AAECAaIHBsPhA6b5A8f5A72ABL+ABO2ABAyqywPf3QPn3QPz3QOq6wOf9AOh9AOi9AOj9QOm9QP1nwT2nwQA decodeable
  @doc """
  Decode a deckcode into a Deck struct
  ## Example
  iex> Backend.Hearthstone.Deck.decode("blablabla")
  {:error, "Couldn't decode deckstring"}
  iex> {:ok, deck} = Backend.Hearthstone.Deck.decode("AAECAR8BugMAAA=="); deck.deckcode
  "AAECAR8BugMAAA=="
  """
  @spec decode(String.t()) :: {:ok, t()} | {:error, String.t() | any}
  def decode(""), do: {:error, "Couldn't decode deckstring"}

  def decode(deckcode) do
    with no_comments <- deckcode |> remove_comments() |> String.trim(),
         {:ok, decoded} <- base64_decode(no_comments),
         list <- :binary.bin_to_list(decoded),
         chunked <- chunk_parts(list),
         [0, 1, format, 1, hero | card_parts] <- parts(chunked),
         {singles, rest} <- take_singles(card_parts),
         {doubles, rest} <- take_doubles(rest),
         {multi, _rest} <- take_multi(rest),
         uncanonical_cards <- singles ++ doubles ++ multi,
         cards <- canonicalize_cards(uncanonical_cards) do
      {class, hero} = deckcode_class_hero(hero, cards)

      {:ok,
       %__MODULE__{
         format: format,
         hero: hero,
         cards: cards,
         deckcode: no_comments,
         class: class
       }}
    else
      {:error, reason} -> {:error, reason}
      _ -> String.slice(deckcode, 0, String.length(deckcode) - 1) |> decode()
    end
  end

  def take_singles([count | rest]), do: Enum.split(rest, count)

  def take_doubles([count | rest]) do
    {to_double, new_rest} = Enum.split(rest, count)
    {to_double ++ to_double, new_rest}
  end

  def take_multi([count | rest]) do
    {multi, new_rest} = Enum.split(rest, count * 2)

    cards =
      multi
      |> Enum.chunk_every(2)
      |> Enum.flat_map(fn [card, count] ->
        for _ <- 1..count, do: card
      end)

    {cards, new_rest}
  end

  @spec deckcode_class_hero(integer, [integer]) :: {String.t(), String.t()}
  def deckcode_class_hero(hero, cards) do
    with {c, _h} when c in [nil, "NEUTRAL"] <- {Hearthstone.class(hero), hero} do
      class = most_frequent_class(cards) || "NEUTRAL"
      hero = get_basic_hero(class)
      {class, hero}
    end
  end

  @spec deckcode_class(integer, [integer]) :: String.t()
  def deckcode_class(hero, cards) do
    {class, _hero} = deckcode_class_hero(hero, cards)
    class
  end

  defp most_frequent_class(cards) do
    cards
    |> Enum.map(&Hearthstone.class/1)
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.filter(&(&1 != "NEUTRAL"))
    |> Enum.at(0)
  end

  defp parts(chunked) do
    try do
      Enum.map(chunked, &Varint.LEB128.decode/1)
    rescue
      _ -> :error
    end
  end

  defp base64_decode(target) do
    fixed =
      String.replace(target, [",", "."], "")
      |> String.split(" ")
      |> Enum.at(0)

    with :error <- fixed |> Base.decode64(),
         :error <- (fixed <> "==") |> Base.decode64(),
         :error <- (fixed <> "++") |> Base.decode64(),
         :error <- (fixed <> "+") |> Base.decode64() do
      (fixed <> "=") |> Base.decode64()
    end
  end

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
  def format_name(3), do: "Classic"
  def format_name(9001), do: "Duels"
  def format_name(666), do: "Mercenaries"

  def get_canonical_hero(hero, cards) when is_integer(hero) do
    hero
    |> deckcode_class(cards)
    |> case do
      class when is_binary(class) -> get_basic_hero(class)
      _ -> hero
    end
  end

  @spec get_basic_hero(String.t() | integer) :: integer
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_basic_hero(class) do
    class
    |> normalize_class_name()
    |> case do
      # TODO: CHECK THIS
      "DEATHKNIGHT" -> 78_065
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

  @doc """
  Converts it to single word upper case

  ## Example
  iex> Backend.Hearthstone.Deck.normalize_class_name("Demon    HuNter")
  "DEMONHUNTER"
  iex> Backend.Hearthstone.Deck.normalize_class_name("ROGUE")
  "ROGUE"
  iex> Backend.Hearthstone.Deck.normalize_class_name("Death knight")
  "DEATHKNIGHT"

  """

  @spec normalize_class_name(String.t()) :: String.t()
  def normalize_class_name(<<class::binary>>),
    do:
      class
      |> String.upcase()
      |> String.replace(~r/\s/, "")

  def normalize_class_name(not_string), do: not_string

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

  def canonical_constructed_deckcode(code) when is_binary(code) do
    case decode(code) do
      {:ok, deck = %{cards: cards}} when length(cards) > 14 and length(cards) < 41 ->
        {:ok, deck |> deckcode()}

      _ ->
        {:error, "Not a constructed deckcode"}
    end
  end

  def canonical_constructed_deckcode(_), do: {:error, "Invalid argument"}

  def sort(decks), do: decks |> Enum.sort_by(&class/1)

  def class(deck) do
    with nil <- deck.class do
      deck.hero |> Hearthstone.class()
    end
  end

  def create_comparison_map(decklists = [code | _]) when is_binary(code) do
    decklists |> Enum.map(&decode!/1) |> create_comparison_map()
  end

  def create_comparison_map(decks = [%__MODULE__{} | _]) do
    decks
    |> Enum.flat_map(& &1.cards)
    |> Enum.uniq()
    |> Enum.map(&Hearthstone.get_card/1)
    |> Hearthstone.sort_cards()
  end

  def equals(first, second), do: equal([first, second])

  def equal(decks) when is_list(decks) do
    num_different =
      decks
      |> Enum.map(fn deck ->
        deck
        |> case do
          d = %__MODULE__{} -> {:ok, d}
          code when is_binary(code) -> decode(code)
          _ -> {:error, :not_valid}
        end
        |> case do
          {:ok, d} -> deckcode(d)
          other -> other
        end
      end)
      |> Enum.uniq()
      |> Enum.count()

    num_different == 1
  end

  def equal(_), do: false

  def classes() do
    [
      "DEATHKNIGHT",
      "DEMONHUNTER",
      "DRUID",
      "HUNTER",
      "MAGE",
      "PALADIN",
      "PRIEST",
      "ROGUE",
      "SHAMAN",
      "WARLOCK",
      "WARRIOR"
    ]
  end

  @spec rune_cost(t()) :: RuneCost.t()
  def rune_cost(%{cards: cards}) do
    cards
    |> Enum.map(&(&1 |> Hearthstone.get_card()))
    |> Enum.filter(& &1)
    |> Enum.map(&Map.get(&1, :rune_cost))
    |> Enum.reduce(RuneCost.empty(), &RuneCost.maximum/2)
  end

  def cost(%{cards: cards}) do
    cards
    |> Enum.map(&card_cost/1)
    |> Enum.sum()
  end

  defp card_cost(card) when is_integer(card), do: Hearthstone.get_card(card) |> card_cost()
  # core_set
  defp card_cost(%{card_set_id: 1637}), do: 0
  defp card_cost(%{rarity: %{normal_crafting_cost: nil}}), do: 0
  defp card_cost(%{rarity: %{normal_crafting_cost: cost}}), do: cost
  defp card_cost(%{set: "CORE"}), do: 0
  defp card_cost(%{rarity: "FREE"}), do: 0
  defp card_cost(%{rarity: "COMMON"}), do: 40
  defp card_cost(%{rarity: "RARE"}), do: 100
  defp card_cost(%{rarity: "EPIC"}), do: 400
  defp card_cost(%{rarity: "LEGENDARY"}), do: 1600
  defp card_cost(_), do: 0
end
