defmodule Backend.Hearthstone.Deck do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Hearthstone.Card.RuneCost
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.CardBag
  alias Backend.DeckArchetyper
  alias Backend.HearthstoneJson.Card, as: JsonCard
  alias Backend.Hearthstone.Deck.Sideboard

  @required [:cards, :hero, :format, :deckcode]
  @optional [:hsreplay_archetype, :class, :archetype, :cost]
  @type t :: %__MODULE__{}
  schema "deck" do
    field(:cards, {:array, :integer})
    field(:deckcode, :string)
    field(:format, :integer)
    field(:hero, :integer)
    field(:class, :string)
    field(:archetype, Ecto.Atom, default: nil)
    field(:hsreplay_archetype, :integer, default: nil)
    field(:cost, :integer, default: nil)
    embeds_many(:sideboards, Sideboard, on_replace: :delete)
    timestamps()
  end

  def unique_cards_with_sideboards(%{cards: cards, sideboards: sideboards}) do
    sideboard_cards = Enum.map(sideboards, & &1.card)
    Enum.uniq(cards ++ sideboard_cards)
  end

  @doc false
  def changeset(c, attrs = %{hsreplay_archetype: %{id: id}}) do
    changeset(c, attrs |> Map.put(:hsreplay_archetype, id))
  end

  @doc false
  def changeset(c, attrs_raw = %{deckcode: _, cost: _}) do
    attrs = sort_cards(attrs_raw)

    c
    |> cast(attrs, @required ++ @optional)
    |> cast_embed(:sideboards)
    |> validate_required(@required)
  end

  def changeset(c, %{cards: _, format: _, hero: _} = a) do
    attrs =
      a
      |> Map.put(:deckcode, deckcode(a))
      |> Map.put(:cost, cost(a))

    changeset(c, attrs)
  end

  def cards_and_deckcode_changeset(deck) do
    attrs = %{
      cards: canonicalize_cards(deck.cards),
      sideboards: canonicalize_sideboards(deck.sideboards) |> Enum.map(&Map.from_struct/1),
      deckcode: deckcode(deck)
    }

    deck
    |> cast(attrs, [:cards, :deckcode])
    |> cast_embed(:sideboards)
  end

  def update_archetype_changeset(deck, archetype) do
    cast(deck, %{archetype: archetype}, [:archetype])
  end

  def set_cost_changeset(deck) do
    cost = cost(deck)
    cast(deck, %{cost: cost}, [:cost])
  end

  def change_format(deck, format) do
    deck
    |> cast(%{format: format}, [:format])
  end

  @spec sort_card_ids([integer()]) :: [integer()]
  def sort_card_ids([]), do: []

  def sort_card_ids([a | _] = ids) when is_integer(a) do
    Enum.sort(ids, :asc)
  end

  defp sort_cards(%{cards: cards = [a | _]} = attrs) when is_integer(a) do
    new_cards = sort_card_ids(cards)
    Map.put(attrs, :cards, new_cards)
  end

  defp sort_cards(attrs), do: attrs

  @spec card_mana_cost(t(), Card.card()) :: integer()
  def card_mana_cost(_, nil), do: nil

  def card_mana_cost(%{sideboards: [_ | _] = sideboards}, card) do
    if Card.zilliax_3000?(card) do
      sideboards
      |> zilliax_modules_sideboards()
      |> Enum.map(fn %{card: card_id, count: count} ->
        case Hearthstone.get_card(card_id) do
          nil -> 0
          card -> Card.cost(card) * count
        end
      end)
      |> Enum.sum()
    else
      Card.cost(card)
    end
  end

  def card_mana_cost(_, card), do: Card.cost(card)

  @spec sideboards_count(t() | Sideboard.t(), integer()) :: integer()
  def sideboards_count(sideboards_or_deck, sideboard_id) do
    case filter_sideboards(sideboards_or_deck, sideboard_id) do
      [] ->
        0

      sideboards ->
        sideboards
        |> Enum.map(& &1.count)
        |> Enum.sum()
    end
  end

  @spec zilliax_modules_sideboards(t() | [Sideboard.t()]) :: [integer()]
  def zilliax_modules_sideboards(sideboards_or_deck),
    do: filter_sideboards(sideboards_or_deck, Card.zilliax_3000())

  @spec filter_sideboards(t() | [Sideboard.t()], integer()) :: [integer()]
  def filter_sideboards(%{sideboards: sideboards}, sideboard_id),
    do: filter_sideboards(sideboards, sideboard_id)

  def filter_sideboards(sideboards, sideboard_id) do
    Enum.filter(sideboards, &(&1.sideboard == sideboard_id))
  end

  @spec zilliax_modules_cards(t() | [Sideboard.t()]) :: [Card.t()]
  def zilliax_modules_cards(sideboards_or_deck),
    do: sideboard_cards(sideboards_or_deck, Card.zilliax_3000())

  @spec etc_sideboard_cards(t() | [Sideboard.t()]) :: [Card.t()]
  def etc_sideboard_cards(sideboards_or_deck),
    do: sideboard_cards(sideboards_or_deck, Card.etc_band_manager())

  @spec sideboard_cards(t() | [Sideboard.t()], integer()) :: [Card.t()]
  def sideboard_cards(sideboards_or_deck, sideboard_id) do
    for %{card: card_id} <- filter_sideboards(sideboards_or_deck, sideboard_id),
        card = Hearthstone.get_card(card_id) do
      card
    end
  end

  @type deckcode_opt :: {:deckcode, boolean()}
  @spec deckcode(t(), [deckcode_opt]) :: String.t()
  def deckcode(%{cards: c, hero: h, format: f, sideboards: s}, opts \\ []),
    do: deckcode(c, h, f, s, opts)

  @doc """
  Calculate the deckcode from deck parts.
  Doesn't support decks with more than 2 copies of a card
  """
  @spec deckcode([integer], integer, integer, [Sideboard.t()], [deckcode_opt]) :: String.t()
  def deckcode(c, hero, format, sideboards_unmapped \\ [], opts \\ []) do
    use_deckcode_copy = Keyword.get(opts, :deckcode_copy, true)

    card_ids =
      if use_deckcode_copy do
        c |> Enum.map(&CardBag.deckcode_copy_id/1)
      else
        c
      end

    cards =
      card_ids
      |> Enum.frequencies()
      |> Enum.group_by(fn {_card, freq} -> freq end, fn {card, _freq} -> card end)

    sideboards = canonicalize_sideboards(sideboards_unmapped, &CardBag.deckcode_copy_id/1)

    ([0, 1, format, 1, get_canonical_hero(hero, c)] ++
       deckcode_part(cards[1]) ++
       deckcode_part(cards[2]) ++
       multi_deckcode_part(cards) ++
       sideboards_deckcode_part(sideboards))
    |> Enum.into(<<>>, fn i -> Varint.LEB128.encode(i) end)
    |> Base.encode64()
  end

  defp sideboards_deckcode_part([]), do: [0]

  defp sideboards_deckcode_part(sideboards) do
    {optimized, unoptimized} =
      sideboards
      |> Enum.group_by(& &1.count)
      |> Map.put_new(1, [])
      |> Map.put_new(2, [])
      |> Map.split([1, 2])

    optimized_parts =
      optimized
      |> Enum.flat_map(fn {_count, sideboards} ->
        s =
          sideboards
          |> Enum.sort_by(& &1.sideboard)
          |> Enum.sort_by(& &1.card)
          |> Enum.flat_map(&[&1.card, &1.sideboard])

        [Enum.count(sideboards) | s]
      end)

    unoptimized_parts =
      unoptimized
      |> Enum.flat_map(fn {_, sideboards} ->
        sideboards
        |> Enum.sort_by(& &1.sideboard)
        |> Enum.sort_by(& &1.card)
        |> Enum.flat_map(&[&1.count, &1.card, &1.sideboard])
      end)

    [1 | optimized_parts] ++ [Enum.count(unoptimized_parts) | unoptimized_parts]
  end

  defp multi_deckcode_part(cards) do
    multi_cards = Map.drop(cards, [0, 1, 2])

    multi_part =
      Enum.flat_map(multi_cards, fn {count, cards} ->
        cards
        |> Enum.sort()
        |> Enum.flat_map(&[&1, count])
      end)

    num_multi = div(Enum.count(multi_part), 2)

    [num_multi | multi_part]
  end

  @spec canonicalize_sideboards([Sideboard.t()]) :: [Sideboard.t()]
  def canonicalize_sideboards(sideboards, card_mapper \\ &Hearthstone.canonical_id/1) do
    sideboards
    |> map_sideboard_cards(card_mapper)
    |> deduplicate_sideboards()
    |> ensure_zilly_art()
  end

  defp map_sideboard_cards(sideboards, card_mapper) do
    Enum.map(sideboards, fn %{card: card} = s ->
      %{s | card: card_mapper.(card)}
    end)
  end

  @spec deduplicate_sideboards([Sideboard.t()]) :: [Sideboard.t()]
  defp deduplicate_sideboards(sideboards) do
    Enum.group_by(sideboards, &{&1.card, &1.sideboard})
    |> Enum.map(fn {{_card, _sideboard}, [first | _] = sideboards} ->
      count = sideboards |> Enum.map(& &1.count) |> Enum.sum()
      Map.put(first, :count, count)
    end)
  end

  defp ensure_zilly_art(sideboards) do
    zilly_sideboards =
      Enum.group_by(sideboards, & &1.sideboard)
      |> Enum.find_value(fn {sideboard_id, sideboards} ->
        Card.zilliax_3000?(sideboard_id) and sideboards
      end)

    if !zilly_sideboards or Enum.any?(zilly_sideboards, &Card.zilliax_art?(&1.card)) do
      sideboards
    else
      art = %{count: 1, card: Card.pink_zilly(), sideboard: Card.zilliax_3000()}

      [art | sideboards]
      |> Enum.sort_by(& &1.card)
    end
  end

  @spec canonicalize_cards([integer]) :: [integer]
  def canonicalize_cards(cards), do: Enum.map(cards, &Hearthstone.canonical_id/1)

  @spec deckcode_part([integer] | nil) :: [integer]
  defp deckcode_part(nil), do: [0]
  defp deckcode_part(cards), do: [Enum.count(cards) | cards |> Enum.sort()]

  @class_name_map %{
    "DEATHKNIGHT" => "Death Knight",
    "DEMONHUNTER" => "Demon Hunter",
    "DRUID" => "Druid",
    "HUNTER" => "Hunter",
    "MAGE" => "Mage",
    "PALADIN" => "Paladin",
    "PRIEST" => "Priest",
    "ROGUE" => "Rogue",
    "SHAMAN" => "Shaman",
    "WARLOCK" => "Warlock",
    "WARRIOR" => "Warrior"
  }

  @spec class_name(String.t() | Deck.t()) :: String.t()
  def class_name(%{class: class}) when is_binary(class),
    do: class |> String.upcase() |> class_name()

  def class_name(%{hero: h}) do
    case Hearthstone.class(h) do
      nil -> ""
      class -> class |> String.upcase() |> class_name()
    end
  end

  def class_name(class) do
    Map.get(@class_name_map, class, class)
  end

  @spec class_from_class_name(class_name :: String.t()) ::
          {:ok, class :: String.t()} | {:error, class_name :: String.t()}
  def class_from_class_name("Deathknight"), do: {:ok, "DEATHKNIGHT"}
  def class_from_class_name("Demonhunter"), do: {:ok, "DEMONHUNTER"}

  def class_from_class_name(class_name) do
    case Enum.find_value(@class_name_map, fn {class, name} -> if name == class_name, do: class end) do
      class when is_binary(class) -> {:ok, class}
      _ -> {:error, class_name}
    end
  end

  def short_class_name(class) do
    case class_name(class) do
      "Death Knight" -> "DK"
      "Demon Hunter" -> "DH"
      "Paladin" -> "Pa"
      "Priest" -> "Pr"
      "Warrior" -> "Warr"
      "Warlock" -> "Wlk"
      other -> String.at(other, 0)
    end
  end

  def archetype(%{archetype: a}) when is_binary(a) or (is_atom(a) and not is_nil(a)), do: a
  def archetype(deck), do: DeckArchetyper.archetype(deck)

  def name(deck) do
    base_name = base_name(deck)

    if add_name_modifiers?(deck, base_name) do
      base_name
      |> add_runes(deck)
      |> add_xl(deck)
    else
      base_name
    end
    |> shorten_death_knight()
  end

  @whizbang_heros_archetypes [
    :"Illidan Stormrage",
    :"Al'Akir the Windlord",
    :"Leeroy Jenkins",
    :"Kael'Thas Sunstrider",
    :"C'Thun",
    :Nozdormu,
    :"The Lich King",
    :Xyrella,
    :"Patches the Pirate",
    :"Brann Bronzebeard",
    :"Sir Finley Mrrgglton",
    :"Guff Runetotem",
    :"King Krush",
    :"Forest Warden Omu",
    :"Dr. Boom",
    :"Zul'jin",
    :"N'Zoth, the Corruptor",
    :"Arch-Villain Rafaam",
    :Arfus
  ]
  defp add_name_modifiers?(_, :"Splendiferous Whizbang"), do: false

  defp add_name_modifiers?(%{format: 4}, base_name) when base_name in @whizbang_heros_archetypes,
    do: false

  defp add_name_modifiers?(_, _), do: true

  defp shorten_death_knight(name) do
    String.replace(name, "Death Knight", "DK")
  end

  defp add_xl("XL " <> _ = name, _), do: name

  defp add_xl(name, %{cards: cards}) when is_list(cards) do
    if Enum.count(cards) == 40 do
      add_xl(name)
    else
      name
    end
  end

  defp add_xl(name, _), do: name

  defp add_xl(name) do
    base_name = String.replace(name, "XL ", "")
    "XL " <> base_name
  end

  def add_runes("STD " <> name, deck) do
    "STD " <> add_runes(name, deck)
  end

  def add_runes(name, %{cards: cards} = deck) when is_list(cards) do
    if add_rune_modifiers?(deck, name) do
      deck
      |> rune_cost()
      |> RuneCost.shorthand()
      # next two lines append " " if it's not empty
      |> Kernel.<>(" ")
      |> String.trim_leading()
      |> Kernel.<>(name)
    else
      name
    end
  end

  def add_runes(name, _), do: name

  defp add_rune_modifiers?(%{class: "DEATHKNIGHT"} = deck, name) do
    rune_shorthand = deck |> rune_cost() |> RuneCost.shorthand()

    cond do
      String.contains?(name, "Rainbow") and "BFU" == rune_shorthand ->
        false

      String.contains?(name, "Frost") and "FFF" == rune_shorthand ->
        false

      String.contains?(name, "Blood") and "BBB" == rune_shorthand ->
        false

      String.contains?(name, "Unholy") and "UUU" == rune_shorthand ->
        false

      true ->
        true
    end
  end

  defp add_rune_modifiers?(_, _), do: true

  def base_name(%{archetype: a}) when not is_nil(a), do: to_string(a)

  def base_name(deck) do
    with nil <- DeckArchetyper.archetype(deck) do
      class_name(deck)
    end
  end

  @doc """
  If the hero isn't available then it defaults to the basic hero for the class
  """
  @spec hero(Deck.t()) :: Card.t() | JsonCard.t()
  def hero(%{hero: hero} = deck) do
    with nil <- Hearthstone.get_card(hero) do
      deck.class
      |> get_basic_hero()
      |> Hearthstone.get_card()
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

  @type decode_opt :: {:canonicalize, boolean()}
  @spec decode!(String.t(), [decode_opt]) :: t()
  def decode!(deckcode, opts \\ []), do: deckcode |> decode(opts) |> Util.bangify()

  # todo make 任务贼：AAECAaIHBsPhA6b5A8f5A72ABL+ABO2ABAyqywPf3QPn3QPz3QOq6wOf9AOh9AOi9AOj9QOm9QP1nwT2nwQA decodeable
  @doc """
  Decode a deckcode into a Deck struct
  ## Example
  iex> Backend.Hearthstone.Deck.decode("blablabla")
  {:error, "Couldn't decode deckstring"}
  iex> {:ok, deck} = Backend.Hearthstone.Deck.decode("AAECAR8BugMAAA=="); deck.deckcode
  "AAECAR8BugMAAAA="
  """
  @spec decode(String.t(), [decode_opt]) :: {:ok, t()} | {:error, String.t() | any}
  def decode(deckcode, opts \\ [])
  def decode("", _opts), do: {:error, "Couldn't decode deckstring"}

  def decode(deckcode, opts) do
    canonicalize = Keyword.get(opts, :canonicalize, true)

    with no_comments <- deckcode |> remove_comments() |> String.trim(),
         {:ok, decoded} <- base64_decode(no_comments),
         list <- :binary.bin_to_list(decoded),
         chunked <- chunk_parts(list),
         [0, 1, format, 1, hero | card_parts] <- parts(chunked),
         {singles, rest} <- take_singles(card_parts),
         {doubles, rest} <- take_doubles(rest),
         {multi, rest} <- take_multi(rest),
         {_success, uncanonical_sideboards, _rest} <- parse_sideboard(rest),
         uncanonical_cards <- singles ++ doubles ++ multi do
      {sideboards, unsorted_cards} =
        if canonicalize do
          {
            canonicalize_sideboards(uncanonical_sideboards),
            canonicalize_cards(uncanonical_cards)
          }
        else
          {
            uncanonical_sideboards,
            uncanonical_cards
          }
        end

      cards = Enum.sort(unsorted_cards)
      {class, hero} = deckcode_class_hero(hero, cards)

      {:ok,
       %__MODULE__{
         format: format,
         hero: hero,
         cards: cards,
         deckcode: deckcode(cards, hero, format, sideboards),
         sideboards: sideboards,
         class: class
       }}
    else
      {:error, reason} -> {:error, reason}
      _ -> String.slice(deckcode, 0, String.length(deckcode) - 1) |> decode()
    end
  end

  @spec parse_sideboard([integer]) :: {:ok | :error, [integer], [integer]}
  defp parse_sideboard([]), do: {:ok, [], []}
  defp parse_sideboard([0 | rest]), do: {:ok, [], rest}

  defp parse_sideboard([1 | sideboard]) do
    {singles, after_singles} = sideboard_optimized(sideboard, 1)
    {doubles, after_doubles} = sideboard_optimized(after_singles, 2)
    {multis, rest} = sideboard_multi(after_doubles)
    {:ok, singles ++ doubles ++ multis, rest}
  end

  # we got
  defp parse_sideboard(rest), do: {:error, [], rest}

  defp sideboard_optimized([count | left], copies) do
    {raw, rest} = Enum.split(left, count * 2)

    sideboards =
      raw
      |> Enum.chunk_every(2)
      |> Enum.map(fn [card, sideboard] ->
        create_sideboard(card, sideboard, copies)
      end)

    {sideboards, rest}
  end

  defp sideboard_multi([count | left]) do
    {raw, rest} = Enum.split(left, count * 3)

    sideboards =
      raw
      |> Enum.chunk_every(2)
      |> Enum.map(fn [card, sideboard, copies] ->
        create_sideboard(card, sideboard, copies)
      end)

    {sideboards, rest}
  end

  defp create_sideboard(card, sideboard, count) do
    %{
      card: card,
      sideboard: sideboard,
      count: count
    }
  end

  defp take_singles([count | rest]), do: Enum.split(rest, count)
  defp take_singles([]), do: {[], []}

  defp take_doubles([count | rest]) do
    {to_double, new_rest} = Enum.split(rest, count)
    {Enum.sort(to_double ++ to_double), new_rest}
  end

  defp take_doubles([]), do: {[], []}

  defp take_multi([0]), do: {[], []}

  defp take_multi([count | rest]) do
    {multi, new_rest} = Enum.split(rest, count * 2)

    cards =
      multi
      |> Enum.chunk_every(2)
      |> Enum.flat_map(fn
        [0] ->
          []

        [card, count] ->
          if count > 40, do: raise("Count too high")
          for _ <- 1..count, do: card
      end)

    {cards, new_rest}
  end

  defp take_multi([]), do: {[], []}

  @spec deckcode_class_hero(integer, [integer]) :: {String.t(), String.t()}
  def deckcode_class_hero(hero, cards) do
    hero_class = Hearthstone.class(hero)

    if hero_class not in [nil, "NEUTRAL"] and
         Enum.any?(cards, &(hero_class == Hearthstone.class(&1))) do
      {hero_class, hero}
    else
      class = most_frequent_class(cards) || hero_class || "NEUTRAL"
      hero = get_basic_hero(class)
      {class, hero}
    end
  end

  @spec deckcode_class(integer, [integer]) :: String.t()
  def deckcode_class(hero, cards) do
    {class, _hero} = deckcode_class_hero(hero, cards)
    class
  end

  def most_frequent_class(cards) do
    cards
    |> Enum.map(&Hearthstone.class/1)
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 1), :desc)
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
      |> String.replace(" ", "+")

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

  @spec format_name(integer | t()) :: String.t()
  def format_name(%{format: format}), do: format_name(format)
  def format_name(1), do: "Wild"
  def format_name(2), do: "Standard"
  def format_name(3), do: "Classic"
  def format_name(4), do: "Twist"
  def format_name(9001), do: "Duels"
  def format_name(666), do: "Mercenaries"
  def format_name(_), do: "UnknownFormat"

  def get_canonical_hero(hero, cards) when is_integer(hero) do
    hero
    |> deckcode_class(cards)
    |> get_basic_hero()
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
        {:ok, deckcode(deck)}

      _ ->
        {:error, "Not a constructed deckcode"}
    end
  end

  def canonical_constructed_deckcode(_), do: {:error, "Invalid argument"}

  def sort(decks), do: decks |> Enum.sort_by(&class/1)

  @spec class(t()) :: String.t()
  def class(deck) do
    with nil <- deck.class,
         nil <- Hearthstone.class(deck) do
      "NEUTRAL"
    end
  end

  @spec extract_class(String.t() | atom()) :: String.t()
  def extract_class(name_or_archetype) when is_atom(name_or_archetype),
    do: name_or_archetype |> to_string() |> extract_class()

  def extract_class(name_or_archetype) when is_binary(name_or_archetype) do
    down = String.downcase(name_or_archetype)

    cond do
      down =~ "death knight" -> "DEATHKNIGHT"
      down =~ "deathknight" -> "DEATHKNIGHT"
      down =~ "demon hunter" -> "DEMONHUNTER"
      down =~ "demonhunter" -> "DEMONHUNTER"
      down =~ "druid" -> "DRUID"
      down =~ "hunter" -> "HUNTER"
      # Spell damage can falsely trigger
      String.ends_with?(down, "mage") -> "MAGE"
      down =~ "paladin" -> "PALADIN"
      down =~ "priest" -> "PRIEST"
      down =~ "rogue" -> "ROGUE"
      down =~ "shaman" -> "SHAMAN"
      down =~ "warlock" -> "WARLOCK"
      down =~ "warrior" -> "WARRIOR"
      name_or_archetype =~ "DK" -> "DEATHKNIGHT"
      name_or_archetype =~ "DH" -> "DEMONHUNTER"
      String.ends_with?(down, "lock") -> "WARLOCK"
      String.ends_with?(down, "adin") -> "PALADIN"
      name_or_archetype =~ "Illidan Stormrage" -> "DEMONHUNTER"
      name_or_archetype =~ "Al'Akir the Windlord" -> "SHAMAN"
      name_or_archetype =~ "Leeroy Jenkins" -> "PALADIN"
      name_or_archetype =~ "Kael'Thas Sunstrider" -> "MAGE"
      name_or_archetype =~ "C'Thun" -> "DRUID"
      name_or_archetype =~ "The Lich King" -> "DEATHKNIGHT"
      name_or_archetype =~ "Xyrella" -> "PRIEST"
      name_or_archetype =~ "Patches the Pirate" -> "ROGUE"
      name_or_archetype =~ "King Krush" -> "HUNTER"
      name_or_archetype =~ "Forest Warden Omu" -> "DRUID"
      name_or_archetype =~ "Dr. Boom" -> "WARRIOR"
      name_or_archetype =~ "Zul'jin" -> "HUNTER"
      name_or_archetype =~ "N'Zoth" -> "WARLOCK"
      name_or_archetype =~ "Brann Bronzebeard" -> "HUNTER"
      name_or_archetype =~ "Guff Runetotem" -> "DRUID"
      name_or_archetype =~ "Arch-Villain Rafaam" -> "WARLOCK"
      name_or_archetype =~ "Arfus" -> "DEATHKNIGHT"
      name_or_archetype =~ "Sir Finley Mrrgglton" -> "PALADIN"
      name_or_archetype =~ "Nozdormu" -> "PALADIN"
      true -> "UNKNOWN"
    end
  end

  def create_comparison_map(decklists = [code | _]) when is_binary(code) do
    decklists |> Enum.map(&decode!/1) |> create_comparison_map()
  end

  def create_comparison_map(decks = [%__MODULE__{} | _]) do
    decks
    |> Enum.flat_map(& &1.cards)
    |> Enum.map(&CardBag.deckcode_copy_id/1)
    |> Enum.uniq()
    |> Enum.map(&Hearthstone.get_card/1)
    |> Hearthstone.sort_cards()
  end

  def equals?(first, second), do: equal([first, second])

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

  @spec deckcode_regex() :: Regex.t()
  def deckcode_regex(modifies \\ nil)

  def deckcode_regex(nil) do
    ~r/^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{15,})(?:[=]){0,5}?$/
  end

  def deckcode_regex(modifiers) do
    deckcode_regex(nil).source
    |> Regex.compile!(modifiers)
  end

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

  @class_rgb %{
    "DEATHKNIGHT" => {108, 105, 154},
    "DEMONHUNTER" => {37, 111, 61},
    "DRUID" => {255, 127, 14},
    "HUNTER" => {44, 160, 44},
    "MAGE" => {23, 190, 207},
    "PALADIN" => {240, 189, 39},
    "PRIEST" => {199, 199, 199},
    "ROGUE" => {127, 127, 127},
    "SHAMAN" => {43, 125, 180},
    "WARLOCK" => {162, 112, 153},
    "WARRIOR" => {200, 21, 24},
    "NEUTRAL" => {43, 45, 47}
  }
  def class_color(class, type \\ :hex)

  def class_color(class, :hex) do
    class_color(class, :rgb)
    |> hex()
  end

  def class_color(class, :rgb) do
    Map.get(@class_rgb, class, {43, 45, 47})
  end

  defp hex({r, g, b}) do
    r_hex = Integer.to_string(r, 16) |> String.pad_leading(2, "0")
    g_hex = Integer.to_string(g, 16) |> String.pad_leading(2, "0")
    b_hex = Integer.to_string(b, 16) |> String.pad_leading(2, "0")
    "##{r_hex}#{g_hex}#{b_hex}"
  end

  @spec rune_cost(t() | [integer()]) :: RuneCost.t()
  def rune_cost(%{cards: cards}), do: rune_cost(cards)

  def rune_cost(cards) do
    cards
    |> Enum.map(&(&1 |> Hearthstone.get_card()))
    |> Enum.filter(& &1)
    |> Enum.map(&Map.get(&1, :rune_cost))
    |> Enum.reduce(RuneCost.empty(), &RuneCost.maximum/2)
  end

  def cost(%{cards: cards} = deck) do
    cards_cost =
      Enum.sum_by(cards, &deckcode_copy_dust_cost/1)

    sideboards_cost =
      Map.get(deck, :sideboards, [])
      |> Enum.filter(&use_sideboard_for_dust_cost?/1)
      |> Enum.sum_by(&(&1.count * deckcode_copy_dust_cost(&1)))

    cards_cost + sideboards_cost
  end

  defp deckcode_copy_dust_cost(card_or_sideboard) do
    card_or_sideboard |> extract_card_id() |> CardBag.deckcode_copy_id() |> Card.dust_cost()
  end

  # # hack for core cards with canonical cards in wild
  # @spec remove_non_standard([Card.t() | Sideboard.t()], t()) :: [Card.t() | Sideboard.t()]
  # defp remove_non_standard(cards_or_sideboards, %{format: 2}) do
  #   standard_slugs = if :lt = NaiveDateTime.compare(NaiveDateTime.utc_now(), ~N[2025-03-25 17:00:00])  do
  #       [
  #         "the-great-dark-beyond",
  #         "perils-in-paradise",
  #         "whizbangs-workshop",
  #         "core",
  #         "event",
  #         "showdown-in-the-badlands",
  #         "titans",
  #         "temp_core_2025",
  #         "event_2025",
  #         "festival-of-legends"
  #       ]
  #   else
  #     Backend.Hearthstone.standard_card_sets()
  #   end

  #   Enum.filter(cards_or_sideboards, fn c ->
  #     case get_card(c) do
  #       %{card_set: %{slug: slug}} -> slug in standard_slugs
  #       _ -> true
  #     end
  #   end)
  # end

  # defp remove_non_standard(cards_or_sideboards, _deck), do: cards_or_sideboards
  defp extract_card_id(id) when is_integer(id), do: id
  defp extract_card_id(%{card: id}) when is_integer(id), do: id
  defp extract_card_id(%{card_id: id}) when is_integer(id), do: id
  defp extract_card_id(%Card{id: id}) when is_integer(id), do: id
  defp extract_card_id(_), do: nil
  # defp get_card(id_or_sideboard) do
  #   with id when is_integer(id) <- extract_card_id(id_or_sideboard) do
  #     Hearthstone.get_card(id)
  #   end
  # end

  @spec use_sideboard_for_dust_cost?(sideboard :: Sideboard.t()) :: boolean()
  defp use_sideboard_for_dust_cost?(%{sideboard: id}) do
    !Card.zilliax_3000?(id)
  end

  def addable?(_deck, nil), do: false

  def addable?(deck, card_id) when is_integer(card_id) do
    addable?(deck, Hearthstone.get_card(card_id))
  end

  def addable?(deck, card) do
    total = total_copies(deck, card)
    max_allowed = Card.max_copies_in_deck(card)
    runes_allowed? = runes_allowed?(deck, card)

    not_tourist_or_can_add_tourist? =
      !Card.tourist?(card) or
        Enum.count(tourists(deck)) < 1

    not_zilly_module_or_zilly_not_full? =
      !Card.zilliax_module?(Card.dbf_id(card)) or missing_zilliax_parts?(deck)

    # max one tourist per deck
    runes_allowed? and total < max_allowed and
      not_tourist_or_can_add_tourist? and not_zilly_module_or_zilly_not_full?
  end

  @max_runes_in_deck 3
  defp runes_allowed?(deck, card) do
    total_runes =
      rune_cost(deck)
      |> RuneCost.maximum(card.rune_cost)
      |> RuneCost.count()

    total_runes <= @max_runes_in_deck
  end

  def total_copies(%{cards: cards, sideboards: sideboards}, card) do
    card_id = CardBag.deckcode_copy_id(card.id)
    in_deck = Enum.count(cards, &(card_id == CardBag.deckcode_copy_id(&1)))

    in_sideboards =
      Enum.filter(sideboards, &(card_id == CardBag.deckcode_copy_id(&1.card)))
      |> Enum.map(& &1.count)
      |> Enum.sum()

    in_deck + in_sideboards
  end

  @spec missing_zilliax_sideboard?(t()) :: boolean()
  def missing_zilliax_sideboard?(%{cards: cards, sideboards: sideboards}) do
    Enum.any?(cards, &Card.zilliax_3000?/1) and
      !Enum.any?(sideboards, &(&1.sideboard == Card.zilliax_3000()))
  end

  @spec missing_zilliax_parts?(t()) :: boolean()
  def missing_zilliax_parts?(deck) do
    Enum.any?(deck.cards, &Card.zilliax_3000?/1) and
      sideboards_count(deck, Card.zilliax_3000()) < 3
  end

  def tourists(deck) do
    deck.cards
    |> Enum.map(&Backend.Hearthstone.get_card/1)
    |> Enum.filter(&(&1 && Card.tourist?(&1)))
  end

  def tourist_class_set_tuples(deck) do
    for %{card_set_id: card_set_id} = t <- tourists(deck),
        {:ok, class} <- [Card.tourist_class(t)] do
      {class, card_set_id}
    end
  end

  @spec replace_cards(t(), Map.t()) :: String.t()
  def replace_cards(deck, new_cards_map) do
    new_cards = Enum.map(deck.cards, &Map.get(new_cards_map, &1, &1))

    deck
    |> Map.put(:cards, new_cards)
    |> deckcode()
    |> decode!()
  end

  @spec replace_cards(t(), integer()) :: String.t()
  def brodeify(deck, to_replace \\ Card.zilliax_3000()) do
    card_map = %{to_replace => Card.ben_brode()}
    replace_cards(deck, card_map)
  end
end

defmodule Backend.Hearthstone.Deck.Sideboard do
  @moduledoc "Holds optional for sideboard info"
  use Ecto.Schema
  import Ecto.Changeset

  @all_attrs [:card, :sideboard, :count]
  @primary_key false
  embedded_schema do
    field(:card, :integer)
    field(:sideboard, :integer)
    field(:count, :integer)
  end

  def changeset(sideboard, attrs) do
    sideboard
    |> cast(Map.new(attrs), @all_attrs)
    |> validate_required(@all_attrs)
  end

  def init(%__MODULE__{} = sideboard), do: sideboard

  def init(%{sideboard: sideboard, count: count, card: card}),
    do: %__MODULE__{sideboard: sideboard, card: card, count: count}
end
