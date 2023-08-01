defmodule BackendWeb.PeriodControllerTest do
  use BackendWeb.ConnCase

  alias Hearthstone.DeckTracker

  @create_attrs %{
    auto_aggregate: true,
    display: "some display",
    hours_ago: 42,
    include_in_deck_filters: true,
    include_in_personal_filters: true,
    period_end: ~N[2023-07-30 23:22:00],
    period_start: ~N[2023-07-30 23:22:00],
    slug: "some slug",
    type: "some type"
  }
  @update_attrs %{
    auto_aggregate: false,
    display: "some updated display",
    hours_ago: 43,
    include_in_deck_filters: false,
    include_in_personal_filters: false,
    period_end: ~N[2023-07-31 23:22:00],
    period_start: ~N[2023-07-31 23:22:00],
    slug: "some updated slug",
    type: "some updated type"
  }
  @invalid_attrs %{
    auto_aggregate: nil,
    display: nil,
    hours_ago: nil,
    include_in_deck_filters: nil,
    include_in_personal_filters: nil,
    period_end: nil,
    period_start: nil,
    slug: nil,
    type: nil
  }

  def fixture(:period) do
    {:ok, period} = DeckTracker.create_period(@create_attrs)
    period
  end

  describe "index" do
    test "lists all periods", %{conn: conn} do
      conn = get(conn, ~p"/torch/periods")
      assert html_response(conn, 200) =~ "Periods"
    end
  end

  describe "new period" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/periods/new")
      assert html_response(conn, 200) =~ "New Period"
    end
  end

  describe "create period" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/torch/periods", period: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/periods/#{id}"

      conn = get(conn, ~p"/periods/#{id}")
      assert html_response(conn, 200) =~ "Period Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/torch/periods", period: @invalid_attrs
      assert html_response(conn, 200) =~ "New Period"
    end
  end

  describe "edit period" do
    setup [:create_period]

    test "renders form for editing chosen period", %{conn: conn, period: period} do
      conn = get(conn, ~p"/periods/#{period}/edit")
      assert html_response(conn, 200) =~ "Edit Period"
    end
  end

  describe "update period" do
    setup [:create_period]

    test "redirects when data is valid", %{conn: conn, period: period} do
      conn = put conn, ~p"/periods/#{period}", period: @update_attrs
      assert redirected_to(conn) == ~p"/periods/#{period}"

      conn = get(conn, ~p"/periods/#{period}")
      assert html_response(conn, 200) =~ "some updated display"
    end

    test "renders errors when data is invalid", %{conn: conn, period: period} do
      conn = put conn, ~p"/periods/#{period}", period: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Period"
    end
  end

  describe "delete period" do
    setup [:create_period]

    test "deletes chosen period", %{conn: conn, period: period} do
      conn = delete(conn, ~p"/periods/#{period}")
      assert redirected_to(conn) == "/periods"

      assert_error_sent 404, fn ->
        get(conn, ~p"/periods/#{period}")
      end
    end
  end

  defp create_period(_) do
    period = fixture(:period)
    {:ok, period: period}
  end
end
