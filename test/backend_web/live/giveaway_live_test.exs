defmodule BackendWeb.GiveawayLiveTest do
  use BackendWeb.ConnCase
  use BackendWeb, :verified_routes
  import Phoenix.LiveViewTest
  alias Backend.Giveaways
  import Backend.GiveawaysFixtures
  import Backend.UserFixtures

  test "visitor sees giveaway details and enter step", %{conn: conn} do
    creator = user_fixture()
    giveaway = giveaway_fixture(%{creator: creator, name: "Special Winter Giveaway"})

    {:ok, _view, html} = live(conn, ~p"/giveaway/#{giveaway.id}")
    assert html =~ "Special Winter Giveaway"
    assert html =~ "Enter the giveaway"
  end

  test "winner sees their specific assigned code", %{conn: _conn} do
    creator = user_fixture()

    giveaway =
      giveaway_fixture(%{
        creator: creator,
        name: "Secret Key Giveaway",
        number_of_winners: 2,
        codes: ["WINNER1_SECRET_KEY", "WINNER2_SECRET_KEY"]
      })

    winner1 = user_fixture(%{battletag: "Alice#1234"})
    winner2 = user_fixture(%{battletag: "Bob#5678"})

    {:ok, _} = Giveaways.enter(giveaway, winner1)
    {:ok, _} = Giveaways.enter(giveaway, winner2)
    {:ok, _} = Giveaways.pick_winners(giveaway, creator)

    # Winner 1 logs in and views the giveaway
    entry1 = Giveaways.get_entry(giveaway, winner1)
    entry2 = Giveaways.get_entry(giveaway, winner2)

    conn1 = BackendWeb.ConnCase.build_conn_with_user(winner1)
    {:ok, view1, html1} = live(conn1, ~p"/giveaway/#{giveaway.id}")

    assert html1 =~ "Congrats! You won!"
    assert has_element?(view1, "#winner_code", entry1.code)
    refute html1 =~ entry2.code

    # Winner 2 logs in and views the giveaway
    conn2 = BackendWeb.ConnCase.build_conn_with_user(winner2)
    {:ok, view2, html2} = live(conn2, ~p"/giveaway/#{giveaway.id}")

    assert html2 =~ "Congrats! You won!"
    assert has_element?(view2, "#winner_code", entry2.code)
    refute html2 =~ entry1.code
  end

  test "creator can save codes and pick winners in LiveView", %{conn: _conn} do
    creator = user_fixture()

    giveaway =
      giveaway_fixture(%{
        creator: creator,
        name: "Creator Managed Giveaway",
        number_of_winners: 2,
        codes: []
      })

    user1 = user_fixture(%{battletag: "Player1#1111"})
    user2 = user_fixture(%{battletag: "Player2#2222"})

    {:ok, _} = Giveaways.enter(giveaway, user1)
    {:ok, _} = Giveaways.enter(giveaway, user2)

    creator_conn = BackendWeb.ConnCase.build_conn_with_user(creator)
    {:ok, view, html} = live(creator_conn, ~p"/giveaway/#{giveaway.id}")

    assert html =~ "Codes / Messages for Winners"
    assert has_element?(view, "#giveaway_codes_form")

    # Creator saves codes via the form
    view
    |> form("#giveaway_codes_form", %{codes: "KEY_ALPHA\nKEY_BETA"})
    |> render_submit()

    updated = Giveaways.get_giveaway!(giveaway.id)
    assert updated.codes == ["KEY_ALPHA", "KEY_BETA"]

    # Creator clicks pick winners
    view
    |> element("#pick_winners_btn")
    |> render_click()

    entries = Giveaways.get_entries(updated, creator)
    winners = Enum.filter(entries, & &1.winner)

    assert length(winners) == 2
    assigned_codes = Enum.map(winners, & &1.code) |> Enum.sort()
    assert assigned_codes == ["KEY_ALPHA", "KEY_BETA"]
  end
end
