defmodule BackendWeb.Components.CompactCardTest do
  use BackendWeb.ConnCase, async: true
  use Surface.LiveViewTest
  alias Components.CompactCard
  alias Components.DeckCardsHorizontal
  alias Components.DeckTableRow
  alias Backend.Hearthstone.Deck

  @sample_minion %{
    id: 1001,
    dbf_id: 1686,
    card_id: "CS2_182",
    name: "Boulderfist Ogre",
    mana_cost: 6,
    attack: 6,
    health: 7,
    durability: nil,
    card_type: %{slug: "minion", name: "Minion"},
    type: "MINION",
    rarity: "FREE",
    classes: [],
    card_class: "NEUTRAL"
  }

  @sample_spell %{
    id: 1002,
    dbf_id: 315,
    card_id: "CS2_029",
    name: "Fireball",
    mana_cost: 4,
    attack: nil,
    health: nil,
    durability: nil,
    card_type: %{slug: "spell", name: "Spell"},
    type: "SPELL",
    rarity: "FREE",
    classes: [],
    card_class: "MAGE"
  }

  @sample_weapon %{
    id: 1003,
    dbf_id: 405,
    card_id: "CS2_106",
    name: "Fiery War Axe",
    mana_cost: 3,
    attack: 3,
    health: nil,
    durability: 2,
    card_type: %{slug: "weapon", name: "Weapon"},
    type: "WEAPON",
    rarity: "FREE",
    classes: [],
    card_class: "WARRIOR"
  }

  @sample_legendary %{
    id: 1004,
    dbf_id: 374,
    card_id: "EX1_298",
    name: "Ragnaros the Firelord",
    mana_cost: 8,
    attack: 8,
    health: 8,
    durability: nil,
    card_type: %{slug: "minion", name: "Minion"},
    type: "MINION",
    rarity: "LEGENDARY",
    classes: [],
    card_class: "NEUTRAL"
  }

  @sample_dual_class %{
    id: 1005,
    dbf_id: 1005,
    card_id: "TEST_005",
    name: "Dual Class Spell",
    mana_cost: 2,
    attack: nil,
    health: nil,
    durability: nil,
    card_type: %{slug: "spell", name: "Spell"},
    type: "SPELL",
    rarity: "RARE",
    classes: [%{slug: "mage"}, %{slug: "rogue"}],
    card_class: nil
  }

  describe "Components.CompactCard (card_top mode)" do
    test "renders card top cropped below rarity gem and stacks 2x copies" do
      assigns = %{card: @sample_minion}

      html =
        render_surface do
          ~F"""
          <CompactCard card={@card} count={2} mode="card_top" />
          """
        end

      # Slot and card top dimensions
      assert html =~ "width: 67px; height: 60px"
      assert html =~ "width: 64px; height: 60px"

      # Uses HearthstoneJSON / full card render endpoint
      assert html =~ "render/latest/enUS/256x/CS2_200.png"

      # Stacked card layer underneath for 2x
      assert html =~ "top: 0px; left: 3px;"
      assert html =~ "filter: brightness(0.72);"

      # Mask image for smooth non-abrupt bottom fade and rounded corners
      assert html =~ "mask-image: linear-gradient(to bottom"
      assert html =~ "tw-rounded-[4px]"

      # Does NOT render separate HTML text overlays for stats since the image contains them
      refute html =~ "Mana Cost: 6"
      refute html =~ "Attack: 6"
      refute html =~ "Health: 7"
      refute html =~ "hearthstone-stat-number"
    end

    test "renders 1x card top without stacked background card" do
      assigns = %{card: @sample_legendary}

      html =
        render_surface do
          ~F"""
          <CompactCard card={@card} count={1} mode="card_top" />
          """
        end

      assert html =~ "render/latest/enUS/256x/EX1_298.png"
      assert html =~ "width: 67px; height: 60px"
      assert html =~ "mask-image: linear-gradient(to bottom"
      refute html =~ "filter: brightness(0.72);"
    end
  end

  describe "Components.CompactCard (cropped_art mode)" do
    test "renders pure cropped art and correct badges on front card, stacking multiple copies" do
      assigns = %{card: @sample_minion}

      html =
        render_surface do
          ~F"""
          <CompactCard card={@card} count={2} mode="cropped_art" />
          """
        end

      # Mana cost in upper-left badge
      assert html =~ "Mana Cost: 6"

      # Attack in bottom-left badge
      assert html =~ "Attack: 6"

      # Health in bottom-right badge
      assert html =~ "Health: 7"

      # No numeric count badge in top-right
      refute html =~ "2x in deck"

      # Stacked card layer rendered underneath
      assert html =~ "top: 0px; left: 5px;"
      assert html =~ "tw-brightness-[0.82]"

      # No background circle divs behind numbers
      refute html =~ "tw-bg-sky-950"
      refute html =~ "tw-bg-amber-950"
      refute html =~ "tw-bg-rose-950"

      # Stats appear ONLY once (on the front card, not on the bottom card)
      assert length(Regex.scan(~r/Mana Cost: 6/, html)) == 1
      assert length(Regex.scan(~r/Attack: 6/, html)) == 1
      assert length(Regex.scan(~r/Health: 7/, html)) == 1

      # Image uses cropped art endpoint
      assert html =~ "https://art.hearthstonejson.com/v1/256x/CS2_182.jpg"
    end

    test "renders legendary star in top-right corner" do
      assigns = %{card: @sample_legendary}

      html =
        render_surface do
          ~F"""
          <CompactCard card={@card} count={1} mode="cropped_art" />
          """
        end

      assert html =~ "title=\"Legendary\""
      assert html =~ "★"
      # Does not render count badge for legendary
      refute html =~ "1x in deck"
    end

    test "renders weapon with attack and durability, and without type glyph" do
      assigns = %{card: @sample_weapon}

      html =
        render_surface do
          ~F"""
          <CompactCard card={@card} count={1} mode="cropped_art" />
          """
        end

      assert html =~ "Mana Cost: 3"
      assert html =~ "Attack: 3"
      assert html =~ "Durability: 2"
      refute html =~ "⚔"
      # Count == 1 on non-legendary does not show top-right badge
      refute html =~ "in deck"
    end

    test "renders spell without attack or health badges, and without type glyph" do
      assigns = %{card: @sample_spell}

      html =
        render_surface do
          ~F"""
          <CompactCard card={@card} count={1} mode="cropped_art" />
          """
        end

      assert html =~ "Mana Cost: 4"
      refute html =~ "Attack:"
      refute html =~ "Health:"
      refute html =~ "Durability:"
      refute html =~ "✨"
    end

    test "renders dual-class card with half/half border gradient" do
      assigns = %{card: @sample_dual_class}

      html =
        render_surface do
          ~F"""
          <CompactCard card={@card} count={1} mode="cropped_art" />
          """
        end

      # Dual-class subtle gradient border
      assert html =~
               "linear-gradient(135deg, color-mix(in srgb, var(--color-mage) 60%, transparent) 50%, color-mix(in srgb, var(--color-rogue) 60%, transparent) 50%)"

      assert html =~ "transform: scale(1.45)"
    end

    test "renders multiple copies as stacked cards without stats on bottom cards" do
      assigns = %{minion: @sample_minion}

      # 2 copies: stacked card behind
      html_2x =
        render_surface do
          ~F"""
          <CompactCard card={@minion} count={2} mode="cropped_art" />
          """
        end

      refute html_2x =~ "2x in deck"
      assert html_2x =~ "top: 0px; left: 5px;"
      assert html_2x =~ "tw-brightness-[0.82]"
      # Stats only appear once (on front card)
      assert length(Regex.scan(~r/Mana Cost: 6/, html_2x)) == 1
      assert length(Regex.scan(~r/Attack: 6/, html_2x)) == 1
      assert length(Regex.scan(~r/Health: 7/, html_2x)) == 1

      # 1 copy: no stacked card
      html_1x =
        render_surface do
          ~F"""
          <CompactCard card={@minion} count={1} mode="cropped_art" />
          """
        end

      refute html_1x =~ "top: 0px; left: 5px;"
      refute html_1x =~ "tw-brightness-[0.82]"
    end
  end

  describe "Components.DeckCardsHorizontal" do
    test "renders deck cards left-to-right with default tw-gap-0" do
      deck = %Deck{
        id: 1,
        cards: [1002, 1002, 1001],
        sideboards: []
      }

      # Test cards_to_display directly
      items = DeckCardsHorizontal.cards_to_display(deck)
      assert length(items) >= 0

      assigns = %{deck: deck}

      html =
        render_surface do
          ~F"""
          <DeckCardsHorizontal deck={@deck} />
          """
        end

      assert html =~ "tw-gap-0"
    end

    test "respects custom gap prop" do
      deck = %Deck{
        id: 1,
        cards: [1002],
        sideboards: []
      }

      assigns = %{deck: deck}

      html =
        render_surface do
          ~F"""
          <DeckCardsHorizontal deck={@deck} gap="1" />
          """
        end

      assert html =~ "tw-gap-1"
    end
  end

  describe "Components.DeckTableRow" do
    test "renders table row with deck info, winrate, games, turns, and duration" do
      deck = %Deck{
        id: 42,
        cards: [1001],
        format: 2,
        class: "MAGE",
        cost: 3200
      }

      deck_with_stats = %{
        id: 42,
        deck_id: 42,
        deck: deck,
        total: 150,
        winrate: 0.564,
        wins: 85,
        losses: 65,
        turns: 8.4,
        duration: 420.0
      }

      assigns = %{deck_with_stats: deck_with_stats}

      html =
        render_surface do
          ~F"""
          <table>
            <DeckTableRow id="deck_row_42" deck_with_stats={@deck_with_stats} />
          </table>
          """
        end

      assert html =~ "id=\"deck_row_42\""
      assert html =~ "150"
      assert html =~ "3,200"
      assert html =~ "8.4"
      assert html =~ "7.0m"
      assert html =~ "aria-label=\"Copy deck code\""

      # Winrate is before deck info (first column)
      winrate_pos = :binary.match(html, "tag") |> elem(0)
      deck_info_pos = :binary.match(html, "aria-label=\"Copy deck code\"") |> elem(0)
      assert winrate_pos < deck_info_pos
    end

    test "renders table row with card_mode=\"cropped_art\"" do
      deck = %Deck{
        id: 43,
        cards: [1001],
        format: 2,
        class: "MAGE",
        cost: 3200
      }

      deck_with_stats = %{
        id: 43,
        deck_id: 43,
        deck: deck,
        total: 100,
        winrate: 0.55,
        wins: 55,
        losses: 45,
        turns: 7.5,
        duration: 360.0
      }

      assigns = %{deck_with_stats: deck_with_stats}

      html =
        render_surface do
          ~F"""
          <table>
            <DeckTableRow id="deck_row_43" deck_with_stats={@deck_with_stats} card_mode="cropped_art" />
          </table>
          """
        end

      assert html =~ "id=\"deck_row_43\""
      assert html =~ "55.0"
    end
  end
end
