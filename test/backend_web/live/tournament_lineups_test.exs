defmodule BackendWeb.TournamentLineupsTest do
  use BackendWeb.ConnCase
  use BackendWeb, :verified_routes
  import Phoenix.LiveViewTest

  alias Backend.Repo
  alias Backend.Hearthstone.Lineup

  @mobile_ua "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"
  @desktop_ua "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

  setup do
    lineup =
      Repo.insert!(%Lineup{
        name: "TestPlayer",
        display_name: "TestPlayer",
        tournament_id: "test_tourney",
        tournament_source: "battlefy"
      })

    %{lineup: lineup}
  end

  test "defaults to expandable mode on desktop", %{conn: conn} do
    conn = put_req_header(conn, "user-agent", @desktop_ua)
    {:ok, view, html} = live(conn, ~p"/tournament-lineups/battlefy/test_tourney")

    # In expandable mode, Open All and Close All buttons are rendered
    assert has_element?(view, "button", "Open All")
    assert has_element?(view, "button", "Close All")
    assert html =~ "Expandable"
  end

  test "defaults to compact mode on mobile", %{conn: conn} do
    conn = put_req_header(conn, "user-agent", @mobile_ua)
    {:ok, view, _html} = live(conn, ~p"/tournament-lineups/battlefy/test_tourney")

    # In compact mode, Open All and Close All buttons are not rendered
    refute has_element?(view, "button", "Open All")
    refute has_element?(view, "button", "Close All")
  end

  test "respects explicit mode=expandable parameter even on mobile", %{conn: conn} do
    conn = put_req_header(conn, "user-agent", @mobile_ua)
    {:ok, view, _html} = live(conn, ~p"/tournament-lineups/battlefy/test_tourney?mode=expandable")

    assert has_element?(view, "button", "Open All")
    assert has_element?(view, "button", "Close All")
  end

  test "respects explicit mode=compact parameter on desktop", %{conn: conn} do
    conn = put_req_header(conn, "user-agent", @desktop_ua)
    {:ok, view, _html} = live(conn, ~p"/tournament-lineups/battlefy/test_tourney?mode=compact")

    refute has_element?(view, "button", "Open All")
    refute has_element?(view, "button", "Close All")
  end

  test "allows toggling mode via dropdown event", %{conn: conn} do
    conn = put_req_header(conn, "user-agent", @mobile_ua)
    {:ok, view, _html} = live(conn, ~p"/tournament-lineups/battlefy/test_tourney")

    # Initially compact on mobile
    refute has_element?(view, "button", "Open All")

    # Switch to expandable
    render_click(element(view, "a[phx-click='change-mode'][phx-value-mode='expandable']"))

    assert has_element?(view, "button", "Open All")

    # Switch back to compact
    render_click(element(view, "a[phx-click='change-mode'][phx-value-mode='compact']"))

    refute has_element?(view, "button", "Open All")
  end

  test "defaults to compact mode on mobile when embedded in wc_2026 without mode prop", %{conn: conn} do
    Repo.insert!(%Lineup{
      name: "Soyorin",
      display_name: "Soyorin",
      tournament_id: "wc_2026",
      tournament_source: "hsesports"
    })

    conn = put_req_header(conn, "user-agent", @mobile_ua)
    {:ok, view, _html} = live(conn, ~p"/wc/2026")

    # In compact mode, Open All and Close All buttons are not rendered
    refute has_element?(view, "button", "Open All")
    refute has_element?(view, "button", "Close All")
  end

  test "defaults to expandable mode on desktop when embedded in wc_2026", %{conn: conn} do
    Repo.insert!(%Lineup{
      name: "Habugabu",
      display_name: "Habugabu",
      tournament_id: "wc_2026",
      tournament_source: "hsesports"
    })

    conn = put_req_header(conn, "user-agent", @desktop_ua)
    {:ok, view, _html} = live(conn, ~p"/wc/2026")

    assert has_element?(view, "button", "Open All")
    assert has_element?(view, "button", "Close All")
  end
end
