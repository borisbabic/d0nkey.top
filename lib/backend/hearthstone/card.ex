defmodule Backend.Hearthstone.Card do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Hearthstone.{
    Deck,
    Set,
    Class,
    Keyword,
    MinionType,
    Rarity,
    RuneCost,
    SpellSchool,
    Type
  }

  @type card() :: %__MODULE__{} | Backend.HearthstoneJson.Card.t() | Hearthstone.Card.t()

  defmacro is_zilliax_art(dbf_id) do
    quote do
      unquote(dbf_id) in [110_440, 110_441, 110_442, 110_443, 110_444, 110_445, 110_446, 112_530]
    end
  end

  def zilliax_art?(dbf_id) do
    dbf_id in [110_440, 110_441, 110_442, 110_443, 110_444, 110_445, 110_446, 112_530]
  end

  defmacro is_card(card) do
    quote do
      is_struct(unquote(card), Backend.Hearthstone.Card) or
        is_struct(unquote(card), Backend.HearthstoneJson.Card) or
        is_struct(unquote(card), Hearthstone.Card)
    end
  end

  @primary_key {:id, :integer, []}
  schema "hs_cards" do
    field(:artist_name, :string)
    field(:attack, :integer)
    belongs_to(:card_set, Set)
    belongs_to(:card_type, Type)
    field(:child_ids, {:array, :integer})
    field(:collectible, :boolean)
    belongs_to(:copy_of_card, Backend.Hearthstone.Card)
    field(:crop_image, :string)
    field(:durability, :integer)
    field(:duels_constructed, :boolean, default: false)
    field(:duels_relevant, :boolean, default: false)
    field(:flavor_text, :string)
    field(:health, :integer)
    field(:image, :string)
    field(:image_gold, :string)
    many_to_many(:keywords, Keyword, join_through: "hs_cards_keywords", on_replace: :delete)
    many_to_many(:classes, Class, join_through: "hs_cards_classes", on_replace: :delete)
    field(:mana_cost, :integer)
    belongs_to(:minion_type, MinionType)
    field(:name, :string)
    belongs_to(:rarity, Rarity)
    field(:slug, :string)
    belongs_to(:spell_school, SpellSchool)
    # field :mercenary_hero, MercenaryHero.t()
    field(:text, :string)
    field(:dust_free, :boolean, default: false)

    embeds_one(:rune_cost, RuneCost, on_replace: :delete)

    belongs_to(:canonical, Backend.Hearthstone.Card)
    belongs_to(:deckcode_copy, Backend.Hearthstone.Card)

    timestamps()
  end

  def changeset(card, %Hearthstone.Card{} = struct) do
    attrs =
      struct
      |> Map.from_struct()
      |> update_duels()
      |> Map.drop([:mercenary_hero])
      |> use_english_fields()

    card
    |> cast(attrs, [
      :id,
      :artist_name,
      :attack,
      :card_set_id,
      :card_type_id,
      :child_ids,
      :collectible,
      :copy_of_card_id,
      :crop_image,
      :durability,
      :duels_constructed,
      :duels_relevant,
      :flavor_text,
      :health,
      :image,
      :image_gold,
      :mana_cost,
      :minion_type_id,
      :name,
      :rarity_id,
      :slug,
      :spell_school_id,
      :dust_free,
      :text
    ])
    |> cast_embed(:rune_cost)
    |> validate_required([:id, :name])
    |> foreign_key_constraint(:card_set_id, name: :hs_cards_card_set_id_fkey)
  end

  def set_referent_card_ids(card, canonical_id, deckcode_copy_id) do
    card
    |> cast(%{canonical_id: canonical_id, deckcode_copy_id: deckcode_copy_id}, [
      :canonical_id,
      :deckcode_copy_id
    ])
    |> validate_required([:canonical_id, :deckcode_copy_id])
  end

  defp update_duels(%{duels: %{constructed: cons, relevant: rel}} = map) do
    map
    |> Map.put(:duels_constructed, cons)
    |> Map.put(:duels_relevant, rel)
    |> Map.drop([:duels])
  end

  defp update_duels(map), do: map

  @doc """
  Cards whose cost in game don't match their data
  Right now it's just zilliax 3000
  """
  @spec special_cost?(card()) :: boolean
  def special_cost?(card), do: zilliax_3000?(card)
  @etc_band_manager 90_749
  def etc_band_manager, do: @etc_band_manager
  @spec etc_band_manager?(card() | integer() | nil) :: boolean
  def etc_band_manager?(nil), do: false
  def etc_band_manager?(id) when is_integer(id), do: id == @etc_band_manager
  def etc_band_manager?(card), do: dbf_id(card) == @etc_band_manager

  @zilliax_3000 102_983
  def zilliax_3000, do: @zilliax_3000
  @spec zilliax_3000?(card() | integer() | nil) :: boolean
  def zilliax_3000?(nil), do: false
  def zilliax_3000?(id) when is_integer(id), do: id == @zilliax_3000
  def zilliax_3000?(card), do: dbf_id(card) == @zilliax_3000

  @pink_zilly 110_446
  def pink_zilly, do: @pink_zilly

  @ben_brode 1768
  def ben_brode, do: @ben_brode

  @renathal 79_767
  def renathal, do: @renathal
  @spec zilliax_3000?(card() | integer() | nil) :: boolean
  def renathal?(nil), do: false
  def renathal?(id) when is_integer(id), do: id == @renathal
  def renathal?(card), do: dbf_id(card) == @renathal

  def use_english_fields(map) do
    [:flavor_text, :image, :image_gold, :name, :text]
    |> Enum.reduce(map, &use_english_field/2)
  end

  defp use_english_field(field, map) do
    new_val =
      with new_map = %{} <- Map.get(map, field, nil) do
        Map.get(new_map, "en_us", nil)
      end

    Map.put(map, field, new_val)
  end

  def put_keywords(changeset, keywords), do: changeset |> put_assoc(:keywords, keywords)
  def put_classes(changeset, classes), do: changeset |> put_assoc(:classes, classes)

  @spec rarity(card()) :: String.t()
  def rarity(%{rarity: rarity}), do: Rarity.upcase(rarity)

  for {method, rarity} <- [
        common?: "COMMON",
        epic?: "EPIC",
        rare?: "RARE",
        legendary?: "LEGENDARY",
        free?: "FREE"
      ] do
    @doc "Check if the card is of the right rarity"
    @spec unquote(method)(card()) :: boolean
    def unquote(method)(card), do: unquote(rarity) == rarity(card)
  end

  @spec max_copies_in_deck(card()) :: integer()
  def max_copies_in_deck(card) do
    if legendary?(card) do
      1
    else
      2
    end
  end

  @spec name(card() | nil) :: String.t() | nil
  def name(%{name: name}), do: name
  def name(_), do: nil

  @doc "Cute = 0 cost minion"
  @spec cute?(card()) :: boolean
  def cute?(card) do
    cost(card) == 0 and type(card) == "MINION" and !special_cost?(card)
  end

  @spec minion?(card()) :: boolean
  def minion?(card), do: type(card) == "MINION"

  @spec spell?(card()) :: boolean
  def spell?(card), do: type(card) == "SPELL"

  @spec weapon?(card()) :: boolean
  def weapon?(card), do: type(card) == "WEAPON"

  @spec location?(card()) :: boolean
  def location?(card), do: type(card) == "LOCATION"

  @spec hero?(card()) :: boolean
  def hero?(card), do: type(card) == "HERO"

  @spec type(card()) :: String.t()
  def type(%{card_type: type}), do: Type.upcase(type)
  def type(%{type: type}), do: Type.upcase(type)

  @spec classes(card()) :: [String.t()]
  def classes(%{card_class: card_class}), do: [card_class]
  def classes(%{classes: classes}), do: Enum.map(classes, &Class.upcase/1)

  @spec in_class?(card(), String.t()) :: boolean()
  def in_class?(card, class), do: class in classes(card)

  @spec class(card()) :: {:ok, String.t()} | {:error, atom()}
  def class(card) do
    case classes(card) do
      [class] -> {:ok, class}
      _ -> {:error, :in_multiple_classes}
    end
  end

  @doc """
  Retrieve the class of the `card`
  If the card is in multiple classes and `specific_class` is one of them then it returns `specific_class`
  """
  @spec class(card(), String.t()) :: {:ok, String.t()} | {:error, atom()}
  def class(card, specific_class) do
    case {classes(card), in_class?(card, specific_class)} do
      {[class], _} -> {:ok, class}
      {_, true} -> {:ok, specific_class}
      _ -> {:error, :in_multiple_classes}
    end
  end

  def neutral?(card) do
    case class(card) do
      {:ok, "NEUTRAL"} -> true
      _ -> false
    end
  end

  @spec cost(card()) :: integer()
  def cost(%{cost: cost}), do: cost
  def cost(%{mana_cost: cost}), do: cost

  @spec dust_cost(card() | integer()) :: integer()
  def dust_cost(card) when is_integer(card), do: Backend.Hearthstone.get_card(card) |> dust_cost()
  # core_set
  def dust_cost(%{dust_free: true}), do: 0
  def dust_cost(%{card_set_id: 1637}), do: 0
  def dust_cost(%{rarity: %{normal_crafting_cost: nil}}), do: 0
  def dust_cost(%{rarity: %{normal_crafting_cost: cost}}), do: cost
  def dust_cost(%{set: "CORE"}), do: 0
  def dust_cost(%{rarity: "FREE"}), do: 0
  def dust_cost(%{rarity: "COMMON"}), do: 40
  def dust_cost(%{rarity: "RARE"}), do: 100
  def dust_cost(%{rarity: "EPIC"}), do: 400
  def dust_cost(%{rarity: "LEGENDARY"}), do: 1600
  def dust_cost(_), do: 0

  @spec set_name(card()) :: String.t() | nil
  def set_name(%{card_set: %{name: name}}), do: name
  def set_name(_), do: nil

  @spec dbf_id(card()) :: integer()
  def dbf_id(%{dbf_id: id}), do: id
  def dbf_id(%{id: id}), do: id

  @spec card_url(card()) :: String.t() | nil
  def card_url(%{image: image}) when is_binary(image), do: image
  def card_url(%Backend.HearthstoneJson.Card{} = c), do: Backend.HearthstoneJson.card_url(c)

  @spec matches_filter?(card(), String.t()) :: boolean
  def matches_filter?(card, search) do
    down_search = String.downcase(search)

    [
      card.name,
      rarity(card),
      set_name(card),
      card.text
      | classes(card)
    ]
    |> Enum.filter(& &1)
    |> Enum.map(&String.downcase/1)
    |> Enum.any?(&(&1 =~ down_search))
  end

  @spec secret?(%__MODULE__{}) :: boolean()
  def secret?(%{keywords: kw}) when is_list(kw), do: Enum.any?(kw, &Keyword.secret?/1)
  def secret?(_), do: false

  @spec questline?(%__MODULE__{}) :: boolean()
  def questline?(%{keywords: kw, text: t}) when is_list(kw),
    do: Enum.any?(kw, &Keyword.questline?/1) and t =~ "Questline:"

  def questline?(_), do: false

  @spec highlander?(%__MODULE__{}) :: boolean()
  def highlander?(%{text: text}) when is_binary(text),
    do: String.downcase(text) =~ "no duplicates"

  def highlander?(_), do: false

  @spec quest?(%__MODULE__{}) :: boolean()
  def quest?(%{keywords: kw, text: t}) when is_list(kw),
    do: Enum.any?(kw, &Keyword.quest?/1) and t =~ "Quest:"

  def quest?(_), do: false

  @tourist_regex ~r/<b>([a-zA-Z ]+) Tourist(.)?<\/b>/
  @spec tourist?(card()) :: boolean()
  def tourist?(%{text: t}) when is_binary(t), do: Regex.match?(@tourist_regex, t)
  def tourist?(_), do: false
  @spec tourist_class(card()) :: {:ok, String.t()} | {:error, atom()}
  def tourist_class(%{text: t}) do
    with [_, class | _] <- Regex.run(@tourist_regex, t),
         normalized <- Deck.normalize_class_name(class),
         true <- normalized in Deck.classes() do
      {:ok, normalized}
    else
      [] -> {:error, :not_a_tourist}
      _ -> {:error, :could_not_extract_class}
    end
  end

  @spec has_keyword?(%__MODULE__{}, String.t()) :: boolean()
  def has_keyword?(%{keywords: kw}, keyword_slug),
    do: Enum.any?(kw, &Keyword.matches?(&1, keyword_slug))

  def has_keyword?(_, _), do: false

  @spec has_spell_school?(%__MODULE__{}, String.t()) :: boolean()
  def has_spell_school?(%{spell_school: ss}, slug), do: SpellSchool.matches?(ss, slug)
  def has_spell_school?(_, _), do: false

  @spec spell_schools(%__MODULE__{}) :: [String.t()]
  def spell_schools(%{spell_school: %{slug: slug}}), do: [slug]
  def spell_schools(_), do: []

  def our_url(%{id: id}), do: "https://www.hsguru.com/card/#{id}"

  @spec same_card_grouper(card()) :: String.t()
  def same_card_grouper(card) do
    text = hack_grouper_text(card)

    "name:#{name(card)}_cost:#{cost(card)}_health:#{card.health}_attack:#{card.attack}_text:#{text}_type:#{type(card)}"
  end

  ## the official api was/is bugged, duplicating some card text
  defp hack_grouper_text(%{text: text}) when is_binary(text) do
    split_position = div(String.length(text), 2)
    {one, two} = String.split_at(text, split_position)

    if String.trim(one) == String.trim(two) do
      String.trim(one)
    else
      String.trim(text)
    end
  end
  defp hack_grouper_text(%{text: text}), do: text
  defp hack_grouper_text(_), do: nil
end

defmodule Backend.Hearthstone.RuneCost do
  @moduledoc "A player entry in the leaderboard snapshot"
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:blood, :integer, default: 0)
    field(:frost, :integer, default: 0)
    field(:unholy, :integer, default: 0)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(Map.from_struct(attrs), [:blood, :frost, :unholy])
  end
end
