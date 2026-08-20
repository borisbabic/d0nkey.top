defmodule BackendWeb.Live.DecksTest do
  use BackendWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.PlayerDto

  @priest_code "AAEBAa0GKMMWg7sCtbsCkNMC/+cC8uwC/KMD184D+9ED+OMDn+sD9PEDu/cDvp8E8J8EhKMEi6ME5bAEx7IE7MkEuNkEuNwExeQEl+8EhoMF/cQFz/YFyPgFw5wG0Z4GmKAGwrYGmcAGj88GheIGjuYGqfUGw4MH25cH9KoHAAABA6G2BP3EBdGeBv3EBcK2Bv3EBQAA"
  @warlock_code "AAEBAf0GKPoO2LsC870C38QCkMcC58sCrs0C8tACnPgC1IYDgIoD2psD/KMDnakD66wDvb4D184D9tYDxt4DzuED+OMDkuQDk+QDpu8D0PkDgfsDg/sDsJEEg6AEhaAE56AE26ME5bAEx7IE1bIE9ccE9c4EmNQEmtQEl+8EAAA="

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
    :ok
  end

  defp generate_btag do
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

  test "fresh requires authentication", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/decks?format=1&force_fresh=yes&min_games=50")
    assert html =~ "You need to login"
  end

  @tag :authenticated
  test "includes wild highlander priest and warlock", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/decks?format=1&rank=all&force_fresh=yes&min_games=50")
    assert html =~ canonical_code(@warlock_code)
    assert html =~ canonical_code(@priest_code)
  end

  @tag :authenticated
  test "Legend excludes priest includes warlock decks", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/decks?format=1&rank=legend&force_fresh=yes&min_games=50")
    refute html =~ canonical_code(@priest_code)
    assert html =~ canonical_code(@warlock_code)
  end

  @tag :authenticated
  test "Archetype excludes warlock and includes priest", %{conn: conn} do
    {:ok, _view, html} =
      live(conn, "/decks?force_fresh=yes&format=1&rank=all&archetype=XL+HL+Thief+Priest&min_games=50")

    refute html =~ canonical_code(@warlock_code)
    assert html =~ canonical_code(@priest_code)
  end

  @tag :authenticated
  test "player_deck_archetype excludes warlock and includes priest", %{conn: conn} do
    {:ok, _view, html} =
      live(
        conn,
        "/decks?format=1&rank=all&player_deck_archetype[]=XL+HL+Thief+Priest&player_deck_archetype[]=Bla Bla&force_fresh=yes&min_games=50"
      )

    refute html =~ canonical_code(@warlock_code)
    assert html =~ canonical_code(@priest_code)
  end

  test "Select All button on DecksLive renders 'Select All' and selects all classes", %{conn: conn} do
    {:ok, view, html} = live(conn, "/decks")

    assert html =~ "Select All"

    view
    |> element("#player_class_dropdown_class_multi button[phx-click=select_all]")
    |> render_click()

    assert_patched(
      view,
      "/decks?player_class[]=DEATHKNIGHT&player_class[]=DEMONHUNTER&player_class[]=DRUID&player_class[]=HUNTER&player_class[]=MAGE&player_class[]=PALADIN&player_class[]=PRIEST&player_class[]=ROGUE&player_class[]=SHAMAN&player_class[]=WARLOCK&player_class[]=WARRIOR"
    )
  end

  defp canonical_code(code) do
    code
    |> Backend.Hearthstone.Deck.decode!()
    |> Backend.Hearthstone.Deck.deckcode()
  end
end
