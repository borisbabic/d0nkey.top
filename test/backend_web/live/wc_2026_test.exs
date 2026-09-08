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
    assert html =~ "Casters:"
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
    assert html =~ "Elimination &amp; Decider matches"
    assert html =~ "Day 4"
    assert html =~ "Quarterfinals"
    assert html =~ "Day 5"
    assert html =~ "Semifinals &amp; Grand Finals"
  end

  test "renders Choose Your Champion and Lineups status", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wc/2026")

    assert html =~ "Choose Your Champion"
    assert html =~ "Vote for Your Champion"
    assert html =~ "2026-09-08T13:00:00"
    assert html =~ "Tournament Lineups"
  end

  test "renders player cards with enlarge modal affordance and lightbox structure", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wc/2026")

    assert html =~ "Click any player to enlarge"
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

  test "renders tournament brackets collapsed by default with sub-bracket day labels", %{conn: conn} do
    Backend.Tournaments.HSEsports.load_csv(Backend.Tournaments.HSEsportsFixtures.sample_csv(), "wc_2026")
    {:ok, _view, html} = live(conn, "/wc/2026")

    assert html =~ "Tournament Brackets"
    assert html =~ "Live match results, Bo5 scores, and class bans"
    assert html =~ "Group A"
    assert html =~ "Group B"
    assert html =~ "Group C"
    assert html =~ "Group D"
    assert html =~ "Double Elimination"
    assert html =~ "Top 2 Advance to Playoffs"
    assert html =~ "Playoff Bracket (Top 8)"
    assert html =~ "Single Elimination Knockout"

    # Brackets are collapsed by default: no <details ... open>
    refute html =~ ~r/<details[^>]+open/

    # Sub-bracket days in groups
    assert html =~ "Days 1 &amp; 3"
    assert html =~ "Days 2 &amp; 3"
    assert html =~ "Day 1"
    assert html =~ "Day 2"
    assert html =~ "Day 3"

    # Sub-bracket days in playoffs
    assert html =~ "Days 4 &amp; 5"
    assert html =~ "Day 4"
    assert html =~ "Day 5"

    assert html =~ "Matchup Matrix"
    assert html =~ "Archetype Stats"
    assert html =~ "/images/icons/demonhunter.png"
    assert html =~ "/images/icons/druid.png"
    assert html =~ "/images/icons/warlock.png"
    assert html =~ "/images/icons/warrior.png"
    assert html =~ "✓"
    assert html =~ "✗"
    assert html =~ "✕"
    assert html =~ "Final"
  end

  test "renders schedule without accordion", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/wc/2026")

    refute html =~ "schedule_accordion"
    refute html =~ "schedule_panel_content"
    assert html =~ "Tournament Schedule"
    assert html =~ "5 Days • Sep 8–13"
  end

  test "renders Ongoing status badge for active incomplete matches", %{conn: conn} do
    Backend.Tournaments.HSEsports.load_csv(Backend.Tournaments.HSEsportsFixtures.sample_ongoing_csv(), "wc_2026")
    {:ok, _view, html} = live(conn, "/wc/2026")

    assert html =~ "Ongoing"
  end
end
