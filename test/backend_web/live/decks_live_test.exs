defmodule BackendWeb.Live.DecksTest do
  use BackendWeb.ConnCase
  import Phoenix.LiveViewTest

  @priest_code "AAEBAa0GKMMWg7sCtbsCkNMC/+cC8uwC/KMD184D+9ED+OMDn+sD9PEDu/cDvp8E8J8EhKMEi6ME5bAEx7IE7MkEuNkEuNwExeQEl+8EhoMF/cQFz/YFyPgFw5wG0Z4GmKAGwrYGmcAGj88GheIGjuYGqfUGw4MH25cH9KoHAAABA6G2BP3EBdGeBv3EBcK2Bv3EBQAA"
  @warlock_code "AAEBAf0GKPoO2LsC870C38QCkMcC58sCrs0C8tACnPgC1IYDgIoD2psD/KMDnakD66wDvb4D184D9tYDxt4DzuED+OMDkuQDk+QDpu8D0PkDgfsDg/sDsJEEg6AEhaAE56AE26ME5bAEx7IE1bIE9ccE9c4EmNQEmtQEl+8EAAA="

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
    {:ok, _view, html} = live(conn, "/decks?format=1&force_fresh=yes&min_games=50")
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
      live(conn, "/decks?force_fresh=yes&format=1&archetype=STD+XL+Priest&min_games=50")

    refute html =~ canonical_code(@warlock_code)
    assert html =~ canonical_code(@priest_code)
  end

  @tag :authenticated
  test "player_deck_archetype excludes warlock and includes priest", %{conn: conn} do
    {:ok, _view, html} =
      live(
        conn,
        "/decks?format=1&player_deck_archetype[]=STD+XL+Priest&player_deck_archetype[]=Bla Bla&force_fresh=yes&min_games=50"
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
