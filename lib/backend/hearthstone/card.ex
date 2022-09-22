defmodule Backend.Hearthstone.Card do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Hearthstone.{
    Set,
    Class,
    Keyword,
    MinionType,
    Rarity,
    SpellSchool,
    Type
  }

  @type card() :: %__MODULE__{} | Backend.HearthstoneJson.Card.t()

  @primary_key {:id, :integer, []}
  schema "hs_cards" do
    field :artist_name, :string
    field :attack, :integer
    belongs_to :card_set, Set
    belongs_to :card_type, Type
    field :child_ids, {:array, :integer}
    field :collectible, :boolean
    belongs_to :copy_of_card, Backend.Hearthstone.Card
    field :crop_image, :string
    field :durability, :integer
    field :duels_constructed, :boolean, default: false
    field :duels_relevant, :boolean, default: false
    field :flavor_text, :string
    field :health, :integer
    field :image, :string
    field :image_gold, :string
    many_to_many :keywords, Keyword, join_through: "hs_cards_keywords", on_replace: :delete
    many_to_many :classes, Class, join_through: "hs_cards_classes", on_replace: :delete
    field :mana_cost, :integer
    belongs_to :minion_type, MinionType
    field :name, :string
    belongs_to :rarity, Rarity
    field :slug, :string
    belongs_to :spell_school, SpellSchool
    # field :mercenary_hero, MercenaryHero.t()
    field :text, :string

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
      :health,
      :image,
      :image_gold,
      :mana_cost,
      :minion_type_id,
      :name,
      :rarity_id,
      :slug,
      :spell_school_id,
      :text
    ])
    |> validate_required([:id, :name])
    |> foreign_key_constraint(:card_set_id, name: :hs_cards_card_set_id_fkey)
  end

  defp update_duels(%{duels: %{constructed: cons, relevant: rel}} = map) do
    map
    |> Map.put(:duels_constructed, cons)
    |> Map.put(:duels_relevant, rel)
    |> Map.drop([:duels])
  end

  defp update_duels(map), do: map

  def use_english_fields(map) do
    [:flavor_text, :image, :image_gold, :name, :text]
    |> Enum.reduce(map, &use_english_field/2)
  end

  defp use_english_field(field, map) do
    case get_in(map, [field, "en_us"]) do
      nil -> Map.put(map, field, nil)
      val -> Map.put(map, field, val)
    end
  end

  def put_keywords(changeset, keywords), do: changeset |> put_assoc(:keywords, keywords)
  def put_classes(changeset, classes), do: changeset |> put_assoc(:classes, classes)

  @spec rarity(card()) :: String.t()
  def rarity(%{rarity: rarity}), do: Rarity.upcase(rarity)

  @spec rarity(card()) :: String.t()
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

  @spec class(card(), String.t()) :: {:ok, String.t()} | {:error, atom()}
  def class(card, specific_class) do
    case {classes(card), in_class?(card, specific_class)} do
      {[class], _} -> {:ok, class}
      {_, true} -> {:ok, specific_class}
      _ -> {:error, :in_multiple_classes}
    end
  end

  @spec cost(card()) :: String.t()
  def cost(%{cost: cost}), do: cost
  def cost(%{mana_cost: cost}), do: cost

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
  def questline?(%{keywords: kw}) when is_list(kw), do: Enum.any?(kw, &Keyword.questline?/1)
  def questline?(_), do: false

  @spec quest?(%__MODULE__{}) :: boolean()
  def quest?(%{keywords: kw}) when is_list(kw), do: Enum.any?(kw, &Keyword.quest?/1)
  def quest?(_), do: false
end
