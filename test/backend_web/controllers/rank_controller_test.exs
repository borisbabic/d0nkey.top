defmodule BackendWeb.RankControllerTest do
  use BackendWeb.ConnCase

  alias Hearthstone.DeckTracker

  @create_attrs %{
    auto_aggregate: true,
    display: "some display",
    include_in_deck_filters: true,
    include_in_personal_filters: true,
    max_legend_rank: 42,
    max_rank: 42,
    min_legend_rank: 42,
    min_rank: 42,
    slug: "some slug"
  }
  @update_attrs %{
    auto_aggregate: false,
    display: "some updated display",
    include_in_deck_filters: false,
    include_in_personal_filters: false,
    max_legend_rank: 43,
    max_rank: 43,
    min_legend_rank: 43,
    min_rank: 43,
    slug: "some updated slug"
  }
  @invalid_attrs %{
    auto_aggregate: nil,
    display: nil,
    include_in_deck_filters: nil,
    include_in_personal_filters: nil,
    max_legend_rank: nil,
    max_rank: nil,
    min_legend_rank: nil,
    min_rank: nil,
    slug: nil
  }

  def fixture(:rank) do
    {:ok, rank} = DeckTracker.create_rank(@create_attrs)
    rank
  end

  describe "index" do
    test "lists all ranks", %{conn: conn} do
      conn = get(conn, ~p"/torch/ranks")
      assert html_response(conn, 200) =~ "Ranks"
    end
  end

  describe "new rank" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/torch/ranks/new")
      assert html_response(conn, 200) =~ "New Rank"
    end
  end

  describe "create rank" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/torch/ranks", rank: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/ranks/#{id}"

      conn = get(conn, ~p"/torch/ranks/#{id}")
      assert html_response(conn, 200) =~ "Rank Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/torch/ranks", rank: @invalid_attrs
      assert html_response(conn, 200) =~ "New Rank"
    end
  end

  describe "edit rank" do
    setup [:create_rank]

    test "renders form for editing chosen rank", %{conn: conn, rank: rank} do
      conn = get(conn, ~p"/torch/ranks/#{rank}/edit")
      assert html_response(conn, 200) =~ "Edit Rank"
    end
  end

  describe "update rank" do
    setup [:create_rank]

    test "redirects when data is valid", %{conn: conn, rank: rank} do
      conn = put conn, ~p"/torch/ranks/#{rank}", rank: @update_attrs
      assert redirected_to(conn) == ~p"/torch/ranks/#{rank}"

      conn = get(conn, ~p"/torch/ranks/#{rank}")
      assert html_response(conn, 200) =~ "some updated display"
    end

    test "renders errors when data is invalid", %{conn: conn, rank: rank} do
      conn = put conn, ~p"/torch/ranks/#{rank}", rank: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Rank"
    end
  end

  describe "delete rank" do
    setup [:create_rank]

    test "deletes chosen rank", %{conn: conn, rank: rank} do
      conn = delete(conn, ~p"/torch/ranks/#{rank}")
      assert redirected_to(conn) == "/ranks"

      assert_error_sent 404, fn ->
        get(conn, ~p"/torch/ranks/#{rank}")
      end
    end
  end

  defp create_rank(_) do
    rank = fixture(:rank)
    {:ok, rank: rank}
  end
end
