defmodule BackendWeb.Live.DecksTest do
  use BackendWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.PlayerDto

  @priest_code "AAEBAa0GKB74B/oO1hGDuwKwvALRwQLZwQLfxAKQ0wLy7AKXhwPmiAO9mQPrmwP8owPIvgPDzAPXzgP70QPi3gP44wOb6wOf6wOm7wO79wO+nwSEowSLowTlsASJsgTHsgSktgSWtwTbuQTsyQSW1ASY1ASa1ASX7wQAAA=="
  @warlock_code "AAEBAf0GKPoO2LsC870C38QCkMcC58sCrs0C8tACnPgC1IYDgIoD2psD/KMDnakD66wDvb4D184D9tYDxt4DzuED+OMDkuQDk+QDpu8D0PkDgfsDg/sDsJEEg6AEhaAE56AE26ME5bAEx7IE1bIE9ccE9c4EmNQEmtQEl+8EAAA="
  # @paladin_code "AAECAZ8FHvvoA8zrA5HsA6bvA/D2A4v4A8D5A9D5A7eABOCLBIuNBJyfBO6fBNCsBKWtBISwBLCyBJa3BNC9BNe9BLLBBLvOBJLUBJrUBKHUBPDxBLKeBZCkBZGkBZKkBQAA"
  @highlander_priest %GameDto{
    player: %PlayerDto{
      battletag: "D0nkey#2470",
      # Diamond 1
      rank: 50,
      legend_rank: nil,
      deckcode: @priest_code,
      class: "PRIEST"
    },
    opponent: %PlayerDto{
      battletag: nil,
      rank: nil,
      legend_rank: nil,
      deckcode: nil,
      class: "WARLOCK"
    },
    game_id: "",
    region: "EU",
    game_type: 7,
    format: 1,
    result: "WON"
  }

  # @highlander_paladin %GameDto{
  #   player: %PlayerDto{
  #     battletag: "D0nkey#2470",
  #     # Diamond 1
  #     rank: 50,
  #     legend_rank: nil,
  #     deckcode: @paladin_code,
  #     class: "PALADIN"
  #   },
  #   opponent: %PlayerDto{
  #     battletag: nil,
  #     rank: nil,
  #     legend_rank: nil,
  #     deckcode: nil,
  #     class: "ROGUE"
  #   },
  #   game_id: "",
  #   game_type: 7,
  #   format: 2,
  #   result: "WON"
  # }

  @highlander_warlock %GameDto{
    player: %PlayerDto{
      battletag: "D0nkey#2470",
      # Diamond 1
      rank: 51,
      legend_rank: 69,
      deckcode: @warlock_code,
      class: "WARLOCK"
    },
    opponent: %PlayerDto{
      battletag: nil,
      rank: nil,
      legend_rank: nil,
      deckcode: nil,
      class: "WARRIOR"
    },
    region: "EU",
    game_id: "",
    game_type: 7,
    format: 1,
    result: "WON"
  }

  setup do
    deck_fixtures(@highlander_priest)
    deck_fixtures(@highlander_warlock)
  end

  defp generate_btag() do
    Ecto.UUID.generate() |> String.replace("-", "") |> Kernel.<>("#0000")
  end

  def deck_fixtures(base_dto, num \\ 201) do
    1..num
    |> Enum.map(fn _ ->
      base_dto
      |> Map.put(:game_id, Ecto.UUID.generate())
      # We don't want the game to be marked as being the same
      |> Map.update!(:opponent, fn o ->
        Map.put(o, :battletag, generate_btag())
      end)
      |> Hearthstone.DeckTracker.handle_game()
    end)
  end

  test "renders", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/decks")
    assert html =~ "Decks"
  end

  test "includes wild highlander priest and warlock", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/decks?format=1&force_fresh=yes")
    assert html =~ canonical_code(@warlock_code)
    assert html =~ canonical_code(@priest_code)
  end

  test "Legend excludes priest includes warlock decks", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/decks?format=1&rank=legend&force_fresh=yes")
    refute html =~ canonical_code(@priest_code)
    assert html =~ canonical_code(@warlock_code)
  end

  test "Archetype exludes warlcok and includes priest", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/decks?format=1&archetype=Highlander Priest&force_fresh=yes")
    refute html =~ canonical_code(@warlock_code)
    assert html =~ canonical_code(@priest_code)
  end

  test "player_deck_arthcetype exludes warlcok and includes priest", %{conn: conn} do
    {:ok, _view, html} =
      live(
        conn,
        "/decks?format=1&player_deck_archetype[]=Highlander Priest&player_deck_archetype[]=Bla Bla&force_fresh=yes"
      )

    refute html =~ canonical_code(@warlock_code)
    assert html =~ canonical_code(@priest_code)
  end

  defp canonical_code(code) do
    code
    |> Backend.Hearthstone.Deck.decode!()
    |> Backend.Hearthstone.Deck.deckcode()
  end
end
