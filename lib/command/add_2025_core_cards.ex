defmodule Command.Add2025CoreCards do
  @moduledoc false
  alias Backend.Hearthstone.Set
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.ExtraCardSet
  alias Hearthstone.Card.RuneCost
  alias Ecto.Multi
  @core_slug "temp_core_2025"
  @core_name "Core 2025"
  def run() do
    ensure_fake_core_set()
    add_cards()
  end

  def ensure_fake_core_set() do
    cs = Backend.Hearthstone.card_sets()

    if !Enum.any?(cs, &(&1.slug == @core_slug)) do
      api_set = %Hearthstone.Metadata.Set{
        id: -69,
        alias_set_ids: [],
        name: @core_name,
        slug: @core_slug,
        non_collectible_count: 0,
        collectible_count: 290,
        non_collectible_revealed_count: 290,
        collectible_revealed_count: 290,
        type: nil
      }

      cs = %Set{} |> Set.changeset(api_set)
      Backend.Repo.insert(cs)
    end
  end

  def add_cards(directory \\ "assets/static/images/core_2025") do
    {:ok, files} = File.ls(directory)

    files
    |> Enum.map(&prepare_file/1)
    |> Enum.reduce(Multi.new(), fn {id, changeset}, multi ->
      if changeset do
        Multi.insert(multi, "#{id}", changeset)
      else
        multi
      end
    end)
    |> Backend.Repo.transaction()
  end

  def prepare_file(file_name) do
    pieces = String.split(file_name, "_")

    {class_and_runes, ["CORE", exp, num, "enUS", name_and_id | _]} =
      Enum.split_while(pieces, &(&1 != "CORE"))

    {name_parts, [id]} = String.split(name_and_id, "-") |> Enum.split(-1)

    changeset =
      case Backend.Hearthstone.get_card(id) do
        %{inserted_at: _} ->
          create_mapping(id)

        _ ->
          name = Enum.join(name_parts, "-")

          [class_raw, rune_cost] =
            case class_and_runes do
              [class] -> [class, nil]
              [class, shorthand] -> [class, RuneCost.from_shorthand(shorthand)]
            end

          existing_card = find_existing_card(name)
          card_id = "CORE_#{exp}_#{num}"

          {attrs, classes} =
            if existing_card do
              {attrs_from_existing(existing_card, id, file_name, card_id), existing_card.classes}
            else
              class = class_raw |> fix_class() |> Backend.Hearthstone.class_by_slug()
              {new_attrs(name, id, rune_cost, file_name, card_id), [class]}
            end

          Card.changeset(%Card{}, attrs)
          |> Card.put_classes(classes)
      end

    {id, changeset}
  end

  def create_mapping(id) do
    %ExtraCardSet{} |> ExtraCardSet.changeset(%{card_id: id, card_set_id: -69})
  end

  def attrs_from_existing(existing_card, id, file_name, card_id) do
    existing_card
    |> Map.from_struct()
    |> Map.put(:id, id)
    |> Map.put(:image, image_url(file_name))
    |> Map.put(:card_set_id, -69)
    |> Map.drop([:image_gold])
    |> Map.put(card_id, :card_id)
  end

  def new_attrs(name, id, rune_cost, file_name, card_id) do
    %{
      id: id,
      # artist_name: nil,
      # attack: nil,
      card_id: card_id,
      card_set_id: -69,
      # card_type_id: nil,
      # child_ids: [],
      collectible: true,
      # copy_of_card_id: nil,
      # crop_image: nil,
      # durability: nil,
      # duels: nil,
      # faction_ids: nil,
      # flavor_text: nil,
      # health: nil,
      image: image_url(file_name),
      # image_gold: nil,
      keyword_ids: [],
      # mana_cost: nil,
      # minion_type_id: nil,
      # multi_class_ids: nil,
      name: Recase.to_title(name),
      # rarity_id: nil,
      # slug: nil,
      # spell_school_id: nil,
      # mercenary_hero: nil,
      rune_cost: rune_cost
      # text: nil
    }
  end

  def image_url(file_name) do
    "/images/core_2025/#{file_name}"
  end

  def fix_class("zz" <> class), do: class
  def fix_class(class), do: class

  def find_existing_card(name) do
    fuzzy_criteria = [
      {"order_by", "name_similarity_#{name}"},
      {"collectible", "yes"},
      {"order_by", "latest"},
      Backend.Hearthstone.not_classic_card_criteria(),
      {"limit", 1}
    ]

    existing = Backend.Hearthstone.cards(fuzzy_criteria) |> Enum.at(0)

    if !!existing and normalize_name(existing.name) == normalize_name(name) do
      existing
    end
  end

  def normalize_name(name) do
    Regex.replace(~r/[^a-zA-Z]/, name, "") |> String.downcase()
  end
end
