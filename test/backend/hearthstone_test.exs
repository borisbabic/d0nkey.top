defmodule Backend.HearthstoneTest do
  use Backend.DataCase
  alias Backend.Hearthstone

  @priest_code "AAEBAa0GKB74B/oO1hGDuwKwvALRwQLZwQLfxAKQ0wLy7AKXhwPmiAO9mQPrmwP8owPIvgPDzAPXzgP70QPi3gP44wOb6wOf6wOm7wO79wO+nwSEowSLowTlsASJsgTHsgSktgSWtwTbuQTsyQSW1ASY1ASa1ASX7wQAAA=="
  test "creates a deck with the class" do
    {:ok, deck} = Hearthstone.create_or_get_deck(@priest_code)
    refute deck.class == nil
  end

  test "sort_cards sorts handle mixed source cards" do
    cards = [
      %Backend.HearthstoneJson.Card{
        type: "MINION",
        set: "PLACEHOLDER_202204",
        rarity: "COMMON",
        mechanics: ["BATTLECRY"],
        health: 2,
        faction: nil,
        elite: nil,
        cost: 2,
        collectible: true,
        card_class: "NEUTRAL",
        attack: 2,
        artist: "Jim Nelson",
        flavor:
          "She creates incredibly affordable wands of all shapes and sizes. But not owls. The owl is all-natural.",
        text: "<b>Battlecry:</b> Add a 1-Cost spell from your class to your hand.",
        name: "Wandmaker",
        dbf_id: 111_471,
        id: "CORE_SCH_160"
      },
      %Backend.Hearthstone.Card{
        id: 103_471,
        artist_name: "Mooncolony ",
        attack: nil,
        card_set_id: 1892,
        card_set: %Backend.Hearthstone.Set{
          id: 1892,
          collectible_count: 183,
          collectible_revealed_count: 183,
          name: "Showdown in the Badlands",
          non_collectible_count: 88,
          non_collectible_revelead_count: nil,
          slug: "showdown-in-the-badlands",
          type: "expansion",
          inserted_at: ~N[2023-10-17 17:31:00],
          updated_at: ~N[2024-03-17 18:37:00]
        },
        card_type_id: 3,
        card_type: %Backend.Hearthstone.Type{
          id: 3,
          game_modes: [1, 4, 5],
          name: "Hero",
          slug: "hero",
          inserted_at: ~N[2022-06-01 23:19:17],
          updated_at: ~N[2024-03-17 18:37:00]
        },
        child_ids: [103_472, 103_473, 103_474, 103_475, 103_476, 103_478, 103_479, 104_455],
        collectible: true,
        copy_of_card_id: nil,
        copy_of_card: nil,
        crop_image:
          "https://d15f34w2p8l1cc.cloudfront.net/hearthstone/76988412c17654776b4a601db18d2893a5dcaec3cb45cebb7d197d1cdf558e0b.png",
        durability: nil,
        duels_constructed: false,
        duels_relevant: false,
        flavor_text:
          "With an uncertain past and a questionable future, Reno was lucky to find his home on the range.",
        health: 30,
        image:
          "https://d15f34w2p8l1cc.cloudfront.net/hearthstone/6b956c7f075b2872f2fcc82e15a4d30ce9c5dd7345c26c5f765c165ab61673a1.png",
        image_gold: nil,
        keywords: [
          %Backend.Hearthstone.Keyword{
            id: 8,
            game_modes: [1, 2, 4, 5, 6, 7],
            name: "Battlecry",
            ref_text: "Does something when you play it from your hand.",
            slug: "battlecry\n",
            text: "Does something when you play it from your hand.",
            inserted_at: ~N[2022-06-01 23:19:17],
            updated_at: ~N[2024-03-17 18:37:00]
          }
        ],
        classes: [
          %Backend.Hearthstone.Class{
            id: 12,
            alternate_hero_card_ids: [],
            card_id: nil,
            hero_power_card_id: nil,
            name: "Neutral",
            slug: "neutral",
            inserted_at: ~N[2022-06-01 23:19:17],
            updated_at: ~N[2024-03-17 18:37:00]
          }
        ],
        mana_cost: 8,
        minion_type_id: nil,
        minion_type: nil,
        name: "Reno, Lone Ranger",
        rarity_id: 5,
        rarity: %Backend.Hearthstone.Rarity{
          id: 5,
          crafting_cost: [1600, 3200],
          dust_value: [400, 1600],
          gold_crafting_cost: 3200,
          gold_dust_value: 1600,
          name: "Legendary",
          normal_crafting_cost: 1600,
          normal_dust_value: 400,
          slug: "legendary",
          inserted_at: ~N[2022-06-01 23:19:17],
          updated_at: ~N[2024-03-17 18:37:00]
        },
        slug: "103471-reno-lone-ranger",
        spell_school_id: nil,
        spell_school: nil,
        text:
          "<b>Battlecry:</b> If your deck has no duplicates, empty the enemy board and limit it to 1 space for a turn. <i>It's high noon!</i>",
        rune_cost: nil,
        inserted_at: ~N[2023-11-03 20:11:19],
        updated_at: ~N[2024-03-13 18:11:15]
      }
    ]

    assert [%{name: "Wandmaker"}, %{name: "Reno, Lone Ranger"}] = Hearthstone.sort_cards(cards)
  end
end
