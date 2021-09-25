defmodule Hearthstone.Metadata.Class do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :alternate_hero_card_ids, [integer()]
    field :card_id, integer() | nil
    field :hero_power_card_id, integer() | nil
    field :name, String.t()
    field :slug, String.t()
  end

  def from_raw_map(map = %{"id" => id, "name" => name, "slug" => slug}) do
    %__MODULE__{
      id: id,
      name: name,
      slug: slug,
      alternate_hero_card_ids: map["alternateHeroCardIds"] || [],
      card_id: map["cardId"],
      hero_power_card_id: map["heroPowerCardId"]
    }
  end
end
