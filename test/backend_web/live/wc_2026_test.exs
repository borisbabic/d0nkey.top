defmodule BackendWeb.WC2026LiveTest do
  use BackendWeb.ConnCase
  use BackendWeb, :verified_routes
  import Phoenix.LiveViewTest

  test "mounts and renders Worlds 2026 page header and navigation", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wc/2026")

    assert html =~ "Worlds 2026"
    assert html =~ "Viewer Guide"
    assert html =~ "Twitch"
    assert html =~ "YouTube"
    assert html =~ "BlizzCon • Anaheim, CA"
    assert html =~ "$500,000 Prize Pool"
    assert html =~ "Broadcast Talent:"
    assert html =~ "Edelweiss"
    assert html =~ "Sottle"
  end

  test "renders all 16 players across groups with names and regions", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wc/2026")

    players = [
      "McBanterFace",
      "Soyorin",
      "mlYanming",
      "hyosung",
      "maxiebon1234",
      "WinBrownie",
      "XiaoT",
      "Fatty",
      "Gaby59",
      "Curfew",
      "Xiaobai",
      "Kwanuu",
      "OTGxhh",
      "Che0nsu",
      "SAVOR",
      "Mesmile"
    ]

    for player <- players do
      assert html =~ player
    end

    assert html =~ "Americas"
    assert html =~ "Europe"
    assert html =~ "APAC"
    assert html =~ "China"
  end

  test "renders tournament schedule with 5 match days", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wc/2026")

    assert html =~ "Tournament Schedule"
    assert html =~ "Day 1"
    assert html =~ "(A–B) Initial &amp; Winner matches"
    assert html =~ "Day 2"
    assert html =~ "(C–D) Initial &amp; Winner matches"
    assert html =~ "Day 3"
    assert html =~ "(A–D) Elimination &amp; Decider matches"
    assert html =~ "Day 4"
    assert html =~ "(Top 8 Single Elimination)"
    assert html =~ "Day 5"
    assert html =~ "Semifinals &amp; Grand Finals"
  end

  test "renders Choose Your Champion and Lineups status", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wc/2026")

    assert html =~ "Choose Your Champion"
    assert html =~ "Vote for Your Champion"
    assert html =~ "Tournament Deck Lineups"
  end

  test "renders player cards with enlarge modal affordance and lightbox structure", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wc/2026")

    assert html =~ "Click any player to enlarge profile"
    assert html =~ "Enlarge"
    assert html =~ "role=\"button\""
    assert html =~ "selectedIndex !== null"
    assert html =~ "open(0)"
    assert html =~ "Full Res"
    assert html =~ "Click outside or press Esc to close"
    assert html =~ "Swipe left / right to change player"
    assert html =~ "Previous / Next"
    assert html =~ "handleTouchStart"
    assert html =~ "handleTouchEnd"
    assert html =~ "player-image-lightbox"
    assert html =~ "!tw-m-0"
    assert html =~ "tw-overflow-y-auto"
    assert html =~ "tw-overscroll-contain"
    assert html =~ "toggleZoom()"
    assert html =~ "Fit Screen"
    assert html =~ "Zoom to Read"
  end
end
