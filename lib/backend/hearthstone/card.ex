defmodule Backend.Hearthstone.Card do
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
  end

  defp update_duels(map = %{duels: %{constructed: cons, relevant: rel}}) do
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
end
