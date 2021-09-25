defmodule Hearthstone.Response.Metadata do
  @moduledoc false

  alias Hearthstone.Metadata.{
    CardBackCategory,
    Class,
    GameMode,
    Keyword,
    MercenaryRole,
    MinionType,
    Rarity,
    SetGroup,
    Set,
    SpellSchool,
    Type
  }

  use TypedStruct

  typedstruct enforce: true do
    field :arena_ids, [integer()]
    field :card_back_categories, [CardBackCategory.t()]
    field :classes, [Class.t()]
    field :filterable_fields, [String.t()]
    field :game_modes, [GameMode.t()]
    field :keywords, [Keyword.t()]
    field :mercenary_roles, [MercenaryRole.t()]
    field :minion_types, [MinionType.t()]
    field :numeric_fields, [String.t()]
    field :rarities, [Rarity.t()]
    field :set_groups, [SetGroup.t()]
    field :sets, [Set.t()]
    field :spell_schools, [SpellSchool.t()]
    field :types, [Type.t()]
  end

  @spec from_raw_map(Map.t()) :: {:ok, __MODULE__.t()} | {:error, any()}
  def from_raw_map(%{
        "arenaIds" => arena_ids,
        "cardBackCategories" => card_back_categories,
        "classes" => classes,
        "filterableFields" => filterable_fields,
        "gameModes" => game_modes,
        "keywords" => keywords,
        "mercenaryRoles" => mercenary_roles,
        "minionTypes" => minion_types,
        "numericFields" => numeric_fields,
        "rarities" => rarities,
        "setGroups" => set_groups,
        "sets" => sets,
        "spellSchools" => spell_schools,
        "types" => types
      }) do
    {
      :ok,
      %__MODULE__{
        arena_ids: arena_ids,
        card_back_categories: card_back_categories |> Enum.map(&CardBackCategory.from_raw_map/1),
        classes: classes |> Enum.map(&Class.from_raw_map/1),
        filterable_fields: filterable_fields,
        game_modes: game_modes |> Enum.map(&GameMode.from_raw_map/1),
        keywords: keywords |> Enum.map(&Keyword.from_raw_map/1),
        mercenary_roles: mercenary_roles |> Enum.map(&MercenaryRole.from_raw_map/1),
        minion_types: minion_types |> Enum.map(&MinionType.from_raw_map/1),
        numeric_fields: numeric_fields,
        rarities: rarities |> Enum.map(&Rarity.from_raw_map/1),
        set_groups: set_groups |> Enum.map(&SetGroup.from_raw_map/1),
        sets: sets |> Enum.map(&Set.from_raw_map/1),
        spell_schools: spell_schools |> Enum.map(&SpellSchool.from_raw_map/1),
        types: types |> Enum.map(&Type.from_raw_map/1)
      }
    }
  end

  def from_raw_map(_), do: {:error, :unable_to_parse_metadata_response}
end
