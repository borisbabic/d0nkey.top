defmodule Hearthstone.Card do
  @moduledoc false
  alias Hearthstone.Card.Duels
  alias Hearthstone.Card.MercenaryHero
  alias Hearthstone.Card.RuneCost

  use TypedStruct

  typedstruct enforce: true do
    field(:artist_name, String.t())
    field(:attack, integer())
    field(:card_set_id, integer())
    field(:card_type_id, integer())
    field(:child_ids, [integer()])
    field(:class_id, integer())
    field(:collectible, integer())
    field(:copy_of_card_id, integer())
    field(:crop_image, String.t())
    field(:durability, integer())
    field(:duels, Duels.t())
    field(:faction_ids, [integer()])
    field(:flavor_text, String.t())
    field(:health, integer())
    field(:id, integer())
    field(:image, String.t())
    field(:image_gold, String.t())
    field(:keyword_ids, [integer()])
    field(:mana_cost, integer())
    field(:minion_type_id, integer())
    field(:multi_class_ids, [integer()])
    field(:name, String.t())
    field(:rarity_id, integer())
    field(:slug, String.t())
    field(:spell_school_id, integer())
    field(:mercenary_hero, MercenaryHero.t())
    field(:rune_cost, RuneCost.t())
    field(:text, String.t())
  end

  @spec from_raw_map(Map.t()) :: {:ok, __MODULE__.t()} | {:error, any()}
  def from_raw_map(raw_map = %{"id" => id}) do
    map = Recase.Enumerable.convert_keys(raw_map, &Recase.to_snake/1)

    {
      :ok,
      %__MODULE__{
        id: id,
        artist_name: map["artist_name"],
        attack: map["attack"],
        card_set_id: map["card_set_id"] |> map_set_id(),
        card_type_id: map["card_type_id"],
        child_ids: map["child_ids"],
        class_id: map["class_id"],
        collectible: map["collectible"] == 1,
        copy_of_card_id: map["copy_of_card_id"],
        crop_image: map["crop_image"],
        durability: map["durability"],
        duels: map["duels"] |> Duels.from_raw_map(),
        faction_ids: faction_ids(map),
        flavor_text: map["flavor_text"],
        health: map["health"],
        image: map["image"],
        image_gold: map["image_gold"],
        keyword_ids: list_or_default(map["keyword_ids"], []),
        mana_cost: map["mana_cost"],
        minion_type_id: map["minion_type_id"],
        multi_class_ids: list_or_default(map["multi_class_ids"], []),
        name: map["name"],
        rarity_id: map["rarity_id"],
        slug: map["slug"],
        spell_school_id: map["spell_school_id"],
        mercenary_hero: MercenaryHero.from_raw_map(map["mercenary_hero"]),
        rune_cost: RuneCost.from_raw_map(map["rune_cost"]),
        text: map["text"]
      }
    }
  end

  def from_raw_map(_), do: {:error, :unable_to_parse_card}

  # FIX YOUR API BLIZZ!!!!!!!!!!!!!!!!
  # HOW CAN YOU HAVE CARDS WITH CARD SETS NOT PRESENT IN YOUR API FOR CARD SETS
  @spec map_set_id(integer()) :: integer()
  # half of legacy seems to be in 3 so moving them all there
  def map_set_id(3), do: 1635
  # hall of fame? Pushing it into legacy too, sigh
  def map_set_id(4), do: 1635
  # some heros? Pushing it into legacy too, sigh
  def map_set_id(17), do: 1635
  def map_set_id(id), do: id

  # the api at first was returning factionId: [id]
  # dunno if it was a mistake or an indication that a card might end up in multiple factions
  def faction_ids(%{"faction_id" => ids}) when is_list(ids), do: ids
  def faction_ids(%{"faction_id" => id}) when is_integer(id), do: [id]
  def faction_ids(%{"faction_ids" => ids}) when is_list(ids), do: ids
  def faction_ids(%{"faction_ids" => id}) when is_integer(id), do: [id]
  def faction_ids(_), do: []

  defp list_or_default(list, _) when is_list(list), do: list
  defp list_or_default(_, default), do: default

  # it's the same card in these cases
  def same_effect?(%__MODULE__{copy_of_card_id: same_id}, %__MODULE__{copy_of_card_id: same_id}),
    do: true

  def same_effect?(%__MODULE__{copy_of_card_id: same_id}, %__MODULE__{id: same_id}), do: true
  def same_effect?(%__MODULE__{id: same_id}, %__MODULE__{id: same_id}), do: true

  # it's the same card in these cases
  def same_effect?(first = %__MODULE__{}, second = %__MODULE__{}) do
    [:attack, :health, :mana_cost, :text, :card_type_id]
    |> Enum.all?(&(Map.get(first, &1) == Map.get(second, &1)))
  end

  def class_ids(%{multi_class_ids: [_ | _] = classes}),
    do: classes

  def class_ids(%{class_id: class_id}),
    do: [class_id]

  # DO NOT COMMIT
  def playable?(%{collectible: collectible}), do: collectible
end

defmodule Hearthstone.Card.Duels do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    field(:constructed, boolean())
    field(:relevant, boolean())
  end

  def from_raw_map(map = %{"relevant" => r}) do
    %__MODULE__{
      constructed: !!map["constructed"],
      relevant: !!r
    }
  end

  def from_raw_map(_) do
    %__MODULE__{
      constructed: false,
      relevant: false
    }
  end
end

defmodule Hearthstone.Card.RuneCost do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    field(:blood, integer())
    field(:frost, integer())
    field(:unholy, integer())
  end

  def from_raw_map(%{
        "blood" => b,
        "frost" => f,
        "unholy" => u
      }) do
    %__MODULE__{
      blood: b,
      frost: f,
      unholy: u
    }
  end

  def from_raw_map(nil), do: nil

  def empty() do
    %__MODULE__{
      blood: 0,
      frost: 0,
      unholy: 0
    }
  end

  @spec maximum(t() | nil, t() | nil) :: t()
  def maximum(%{blood: bf, frost: ff, unholy: uf}, %{blood: bs, frost: fs, unholy: us}) do
    %__MODULE__{
      blood: max(bf, bs),
      frost: max(ff, fs),
      unholy: max(uf, us)
    }
  end

  def maximum(%__MODULE__{} = first, _second), do: first
  def maximum(_first, %__MODULE__{} = second), do: second
  def maximum(_, _), do: empty()

  @spec shorthand(t()) :: String.t()
  def shorthand(%{blood: blood, frost: frost, unholy: unholy}) do
    String.duplicate("B", blood) <>
      String.duplicate("F", frost) <>
      String.duplicate("U", unholy)
  end

  @spec from_shorthand(String.t()) :: t()
  def from_shorthand(shorthand) do
    freq = shorthand |> String.to_charlist() |> Enum.frequencies()

    %__MODULE__{
      blood: Map.get(freq, "B", 0),
      frost: Map.get(freq, "F", 0),
      unholy: Map.get(freq, "U", 0)
    }
  end

  def count(%{blood: b, frost: f, unholy: h}), do: b + f + h
end

defmodule Hearthstone.Card.MercenaryHero do
  @moduledoc false

  use TypedStruct

  alias Hearthstone.Card.MercenaryHero.StatsByLevel

  typedstruct enforce: true do
    field(:collectible, boolean())
    field(:crafting_cost, integer())
    field(:default, boolean())
    field(:merc_id, integer())
    field(:rarity, integer())
    field(:role_id, integer())
    field(:stats_by_level, [StatsByLevel.t()])
  end

  def from_raw_map(%{
        "collectible" => collectible,
        "crafting_cost" => crafting_cost,
        "default" => d,
        "merc_id" => merc_id,
        "role_id" => role_id,
        "rarity" => rarity,
        "stats_by_level" => stats_by_level
      }) do
    %__MODULE__{
      collectible: collectible == 1,
      crafting_cost: crafting_cost,
      default: d == 1,
      merc_id: merc_id,
      role_id: role_id,
      stats_by_level: StatsByLevel.list_from_map(stats_by_level),
      rarity: rarity
    }
  end

  def from_raw_map(_), do: nil
end

defmodule Hearthstone.Card.MercenaryHero.StatsByLevel do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    field(:level, integer())
    field(:attack, integer())
    field(:health, integer())
  end

  @spec list_from_map(Map.t()) :: [StatsByLevel]
  def list_from_map(list) when is_list(list),
    do: Enum.map(list, &list_mapper/1) |> Enum.filter(& &1)

  def list_from_map(_), do: []

  defp list_mapper({level, %{"attack" => attack, "health" => health}}),
    do: %__MODULE__{
      level: level,
      attack: attack,
      health: health
    }

  defp list_mapper(_), do: nil
end
