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

  @image_directory "assets/static/images/core_2025"
  def add_cards(parsed_filter \\ & &1, directory \\ @image_directory) do
    parsed_files(directory)
    |> Enum.filter(parsed_filter)
    |> Enum.map(&prepare_file/1)
    |> Enum.filter(fn {_id, changeset} ->
      changeset
    end)
    |> Enum.reduce(Multi.new(), fn {id, changeset}, multi ->
      Multi.insert(multi, "#{id}", changeset)
    end)
    |> Backend.Repo.transaction()
  end

  def make_short_images(
        source_directory \\ @image_directory,
        destination_directory \\ @image_directory <> "/../raptor_core"
      ) do
    {:ok, files} = File.ls(source_directory)

    for f <- files, %{file_name: file_name, card_id: card_id} <- [parse_file_name(f)] do
      File.copy("#{source_directory}/#{file_name}", "#{destination_directory}/#{card_id}.png")
    end
  end

  def add_card_id(directory \\ @image_directory) do
    directory
    |> parsed_files()
    |> Enum.reduce(Multi.new(), fn %{dbf_id: dbf_id, card_id: card_id}, multi ->
      case Backend.Hearthstone.get_card(dbf_id) do
        %{inserted_at: _} = card ->
          cs = Card.set_card_id(card, card_id)
          Multi.update(multi, "#{dbf_id}_#{card_id}", cs)

        _ ->
          multi
      end
    end)
    |> Backend.Repo.transaction()
  end

  def parsed_files(directory) do
    {:ok, files} = File.ls(directory)
    Enum.map(files, &parse_file_name/1)
  end

  def parse_file_name(file_name) do
    pieces = String.split(file_name, "_")

    {class_runes_card_id, [_, name_and_id | _]} = Enum.split_while(pieces, &(&1 != "enUS"))

    {card_id, class_and_runes} =
      case Enum.reverse(class_runes_card_id) do
        [num, exp, core | class_and_runes] when core in ["CORE", "Core"] ->
          {"#{core}_#{exp}_#{num}", Enum.reverse(class_and_runes)}

        [num, exp | class_and_runes] ->
          {"#{exp}_#{num}", Enum.reverse(class_and_runes)}
      end

    {name_parts, [id]} = String.split(name_and_id, "-") |> Enum.split(-1)
    name = Enum.join(name_parts, " ")

    {class, rune_cost} =
      case class_and_runes do
        [class] -> {fix_class(class), nil}
        [class, shorthand] -> {fix_class(class), RuneCost.from_shorthand(shorthand)}
      end

    %{
      file_name: file_name,
      class_slug: class,
      rune_cost: rune_cost,
      card_id: card_id,
      dbf_id: id,
      name: name
    }
  end

  def prepare_file(%{
        class_slug: class_slug,
        rune_cost: rune_cost,
        card_id: card_id,
        dbf_id: id,
        name: name
      }) do
    changeset =
      case Backend.Hearthstone.get_card(id) do
        %{inserted_at: _} ->
          create_mapping(id)

        _ ->
          existing_card = find_existing_card(name)

          {attrs, classes} =
            if existing_card do
              {attrs_from_existing(existing_card, id, card_id), existing_card.classes}
            else
              class = class_slug |> Backend.Hearthstone.class_by_slug()
              {new_attrs(name, id, rune_cost, card_id), [class]}
            end

          Card.changeset(%Card{}, attrs)
          |> Card.put_classes(classes)
      end

    {id, changeset}
  end

  def create_mapping(id) do
    %ExtraCardSet{} |> ExtraCardSet.changeset(%{card_id: id, card_set_id: -69})
  end

  def attrs_from_existing(existing_card, id, card_id) do
    existing_card
    |> Map.from_struct()
    |> Map.put(:id, id)
    |> Map.put(:image, image_url(card_id))
    |> Map.put(:card_set_id, -69)
    |> Map.drop([:image_gold])
    |> Map.put(card_id, :card_id)
  end

  def new_attrs(name, id, rune_cost, card_id) do
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
      image: image_url(card_id),
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

  def image_url(card_id) do
    "/images/raptor_core/#{card_id}.png"
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
