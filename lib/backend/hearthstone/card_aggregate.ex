defmodule Backend.Hearthstone.CardAggregate do
  @moduledoc "Aggregates stats for cards"
  use TypedStruct

  alias Backend.Hearthstone.CardAggregate.{
    SpellStats,
    MinionStats,
    WeaponStats
  }

  typedstruct enforce: true do
    field :total_count, integer()
    field :total_mana_cost, integer()
    field :keyword_counts, Map.t()

    field :minion_stats, MinionStats.t()
    field :weapon_stats, WeaponStats.t()
    field :spell_stats, SpellStats.t()
  end

  def aggregate(cards) do
    Enum.reduce(cards, empty(), &tally/2)
  end

  def empty() do
    %__MODULE__{
      total_count: 0,
      total_mana_cost: 0,
      keyword_counts: %{},
      minion_stats: MinionStats.empty(),
      weapon_stats: WeaponStats.empty(),
      spell_stats: SpellStats.empty()
    }
  end

  def tally(card, aggregate) do
    %__MODULE__{
      total_count: aggregate.total_count + 1,
      total_mana_cost: aggregate.total_mana_cost + card.mana_cost,
      keyword_counts: tally_keywords(aggregate.keyword_counts, card.keywords),
      minion_stats: MinionStats.tally(card, aggregate.minion_stats),
      weapon_stats: WeaponStats.tally(card, aggregate.weapon_stats),
      spell_stats: SpellStats.tally(card, aggregate.spell_stats)
    }
  end

  def keyword_average(%{keyword_counts: keyword_counts, total_count: total_count}, keyword) do
    Map.get(keyword_counts, keyword, 0) / total_count
  end

  def tally_keywords(tallied_keywords, card_keywords) do
    Enum.reduce(card_keywords, tallied_keywords, &tally_keyword/2)
  end

  defp tally_keyword(%{name: name}, tallied_keywords) do
    Map.update(tallied_keywords, name, 1, &(&1 + 1))
  end

  def string_fields(agg, keywords \\ nil) do
    avg_minion_cost = average_mana_cost(agg.minion_stats) |> float_display
    avg_minion_attack = MinionStats.average_attack(agg.minion_stats) |> float_display
    avg_minion_health = MinionStats.average_health(agg.minion_stats) |> float_display

    avg_weapon_cost = average_mana_cost(agg.weapon_stats) |> float_display
    avg_weapon_attack = WeaponStats.average_attack(agg.weapon_stats) |> float_display
    avg_weapon_durability = WeaponStats.average_durability(agg.weapon_stats) |> float_display

    %{
      "Count" => agg.total_count,
      "Avg Mana Cost" => average_mana_cost(agg) |> float_display(),
      "Minion Count" => agg.minion_stats.total_count,
      "Avg Minion Cost" => avg_minion_cost,
      "Avg Minion Attack" => avg_minion_attack,
      "Avg Minion Health" => avg_minion_health,
      "Avg Minion Stats" => "(#{avg_minion_cost})#{avg_minion_attack}/#{avg_minion_health}",
      "Weapon Count" => agg.weapon_stats.total_count,
      "Avg Weapon Cost" => avg_weapon_cost,
      "Avg Weapon Attack" => avg_weapon_attack,
      "Avg Weapon Health" => avg_weapon_durability,
      "Avg Weapon Stats" => "(#{avg_weapon_cost}) #{avg_weapon_attack}/#{avg_weapon_durability}",
      "Spell Count" => agg.spell_stats.total_count,
      "Avg Spell Cost" => average_mana_cost(agg.spell_stats) |> float_display()
    }
    |> add_keyword_string_fields(agg, keywords)
  end

  defp add_keyword_string_fields(previous_fields, agg, keywords) do
    [
      {"# With", agg.keyword_counts},
      {"# Minions With", agg.minion_stats.keyword_counts},
      {"# Weapons With", agg.weapon_stats.keyword_counts},
      {"# Spells With", agg.spell_stats.keyword_counts}
    ]
    |> Enum.map(fn {prefix, counts} -> {prefix, filter_keywords(counts, keywords)} end)
    |> Enum.reduce(previous_fields, &keyword_string_fields/2)
  end

  defp filter_keywords(counts, nil), do: counts
  defp filter_keywords(counts, []), do: counts
  defp filter_keywords(counts, keywords), do: Map.take(counts, keywords)

  defp float_display(f) when is_float(f), do: Float.round(f, 1)
  defp float_display(f), do: f

  def keyword_string_fields({prefix, keyword_counts}, into) do
    for {keyword, count} <- keyword_counts, into: into do
      {prefix <> keyword, count}
    end
  end

  def average(%{total_count: 0}, _), do: 0
  def average(%{total_count: total}, num), do: num / total
  def average_mana_cost(stats), do: average(stats, stats.total_mana_cost)

  @default_string_fields [
    "Count",
    "Avg Mana Cost",
    "Spell Count",
    "Weapon Count",
    "Minion Count",
    "Avg Minion Cost",
    "Avg Minion Attack",
    "Avg Minion Health"
  ]
  @default_to_string_opts [
    string_fields: @default_string_fields,
    join: "\n"
  ]
  def to_string(agg, opts \\ @default_to_string_opts) do
    actual_opts = opts ++ @default_to_string_opts
    string_fields = Keyword.get(actual_opts, :string_fields)
    join = Keyword.get(actual_opts, :join)

    agg
    |> string_fields_list(string_fields)
    |> Enum.map_join(join, fn {key, val} -> "#{key}: #{val}" end)
  end

  def string_fields_list(agg, string_fields \\ @default_string_fields) do
    agg
    |> string_fields()
    |> Map.take(string_fields)
    |> Enum.to_list()
    |> Enum.sort_by(fn {key, _val} -> Enum.find_index(string_fields, &(&1 == key)) end)
  end
end

defmodule Backend.Hearthstone.CardAggregate.MinionStats do
  @moduledoc "Aggregates minion specific stats"
  use TypedStruct
  alias Backend.Hearthstone.CardAggregate
  alias Backend.Hearthstone.Card

  typedstruct enforce: true do
    field :total_count, integer()
    field :total_mana_cost, integer()
    field :total_health, integer()
    field :total_attack, integer()
    field :keyword_counts, integer()
  end

  def empty() do
    %__MODULE__{
      total_count: 0,
      total_health: 0,
      total_mana_cost: 0,
      total_attack: 0,
      keyword_counts: %{}
    }
  end

  @spec tally(Card.t(), t()) :: t()
  def tally(
        %{
          keywords: keywords,
          health: health,
          mana_cost: mana_cost,
          attack: attack,
          card_type: %{slug: "minion"}
        },
        minion_stats
      ) do
    %__MODULE__{
      keyword_counts: CardAggregate.tally_keywords(minion_stats.keyword_counts, keywords),
      total_mana_cost: minion_stats.total_mana_cost + mana_cost,
      total_attack: minion_stats.total_attack + attack,
      total_health: minion_stats.total_health + health,
      total_count: minion_stats.total_count + 1
    }
  end

  def tally(_, minion_stats), do: minion_stats
  def average_mana_cost(stats), do: CardAggregate.average_mana_cost(stats)
  def average_attack(stats), do: CardAggregate.average(stats, stats.total_attack)
  def average_health(stats), do: CardAggregate.average(stats, stats.total_health)
end

defmodule Backend.Hearthstone.CardAggregate.WeaponStats do
  @moduledoc "Aggregates weapon specific stats"
  use TypedStruct
  alias Backend.Hearthstone.CardAggregate
  alias Backend.Hearthstone.Card

  typedstruct enforce: true do
    field :total_count, integer()
    field :total_durability, integer()
    field :total_mana_cost, integer()
    field :total_attack, integer()
    field :keyword_counts, integer()
  end

  def empty() do
    %__MODULE__{
      total_count: 0,
      total_mana_cost: 0,
      total_durability: 0,
      total_attack: 0,
      keyword_counts: %{}
    }
  end

  @spec tally(Card.t(), t()) :: t()
  def tally(
        %{
          keywords: keywords,
          durability: durability,
          mana_cost: mana_cost,
          attack: attack,
          card_type: %{slug: "weapon"}
        },
        weapon_stats
      ) do
    %__MODULE__{
      keyword_counts: CardAggregate.tally_keywords(weapon_stats.keyword_counts, keywords),
      total_mana_cost: weapon_stats.total_mana_cost + mana_cost,
      total_durability: weapon_stats.total_durability + durability,
      total_attack: weapon_stats.total_attack + attack,
      total_count: weapon_stats.total_count + 1
    }
  end

  def tally(_, weapon_stats), do: weapon_stats

  def average_mana_cost(stats), do: CardAggregate.average_mana_cost(stats)
  def average_attack(stats), do: CardAggregate.average(stats, stats.total_attack)
  def average_durability(stats), do: CardAggregate.average(stats, stats.total_durability)
end

defmodule Backend.Hearthstone.CardAggregate.SpellStats do
  @moduledoc "Aggregates spell specific stats"
  use TypedStruct
  alias Backend.Hearthstone.CardAggregate
  alias Backend.Hearthstone.Card

  typedstruct enforce: true do
    field :total_count, integer()
    field :keyword_counts, integer()
    field :total_mana_cost, integer()
  end

  def empty() do
    %__MODULE__{
      total_count: 0,
      total_mana_cost: 0,
      keyword_counts: %{}
    }
  end

  @spec tally(Card.t(), t()) :: t()
  def tally(
        %{keywords: keywords, mana_cost: mana_cost, card_type: %{slug: "spell"}},
        spell_stats
      ) do
    %__MODULE__{
      keyword_counts: CardAggregate.tally_keywords(spell_stats.keyword_counts, keywords),
      total_mana_cost: spell_stats.total_mana_cost + mana_cost,
      total_count: spell_stats.total_count + 1
    }
  end

  def tally(_, spell_stats), do: spell_stats

  def average_mana_cost(stats), do: CardAggregate.average_mana_cost(stats)
end
