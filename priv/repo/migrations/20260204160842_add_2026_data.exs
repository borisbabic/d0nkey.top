defmodule Backend.Repo.Migrations.Add2026Data do
  use Ecto.Migration
  import Ecto.Query

  @new_year 2026
  @event_set_id -1 * (20_000 + @new_year)
  @event_set_release_date Date.new!(@new_year, 2, 28)
  @event_cards [123_416, 120_648, 120_658, 122_547, 121_676]
  @event_slug "event_#{@new_year}"
  @event_set_name "Event #{new_year}"
  @new_group_name "#{@new_year} Standard"
  @new_group_slug "standard_#{@new_year}"
  @new_group_card_sets [
    "event_#{@new_year}",
    "temp_core_#{@new_year}",
    "across-the-timeways",
    "the-lost-city-of-ungoro",
    "into-the-emerald-dream"
  ]
  @old_group_slug "standard_#{@new_year - 1}"
  @old_group_card_sets [
    "event",
    "core",
    "the-great-dark-beyond",
    "perils-in-paradise",
    "whizbangs-workshop",
    "into-the-emerald-dream",
    "the-lost-city-of-ungoro",
    "across-the-timeways"
  ]
  def up do
    insert_set()
    insert_extra_card_sets()
    insert_new_group()
    update_old_group()
  end

  def down do
    delete_extra_card_sets()
    delete_extra_set()
    delete_new_group()
  end

  def insert_set() do
    repo().insert_all("hs_sets", [
      %{
        id: @event_set_id,
        slug: @event_slug,
        name: @event_set_name,
        release_date: @event_set_release_date,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    ])
  end

  def insert_extra_card_sets() do
    repo().insert_all(
      "hs_extra_card_set",
      Enum.map(@event_cards, fn id -> %{card_id: id, card_set_id: @event_set_id} end)
    )
  end

  def insert_new_group() do
    repo().insert_all(
      "hs_set_groups",
      [
        %{
          name: @new_group_name,
          slug: @new_group_slug,
          card_sets: @new_group_card_sets,
          standard: true,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      ]
    )
  end

  def update_old_group() do
    repo().update_all(
      from(s in "hs_set_groups",
        where: s.slug == ^@old_group_slug
      ),
      set: [card_sets: @old_group_card_sets]
    )
  end

  def delete_extra_set() do
    repo().delete_all(from(s in "hs_sets", where: s.slug == ^@event_slug))
  end

  def delete_extra_card_sets() do
    repo().delete_all(
      from(ecs in "hs_extra_card_set",
        where: ecs.card_set_id == ^@event_set_id and ecs.card_id in ^@event_cards
      )
    )
  end

  def delete_new_group() do
    repo().delete_all(
      from(s in "hs_set_groups",
        where: s.slug == ^@new_group_slug
      )
    )
  end
end
