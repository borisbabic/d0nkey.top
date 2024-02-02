defmodule BackendWeb.RegionControllerTest do
  use BackendWeb.ConnCase

  alias Hearthstone.DeckTracker

  @create_attrs %{auto_aggregate: true, code: "some code", display: "some display"}
  @update_attrs %{
    auto_aggregate: false,
    code: "some updated code",
    display: "some updated display"
  }
  @invalid_attrs %{auto_aggregate: nil, code: nil, display: nil}

  def fixture(:region) do
    {:ok, region} = DeckTracker.create_region(@create_attrs)
    region
  end

  describe "index" do
    test "lists all regions", %{conn: conn} do
      conn = get(conn, ~p"/torch/regions")
      assert html_response(conn, 200) =~ "Regions"
    end
  end

  describe "new region" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/torch/regions/new")
      assert html_response(conn, 200) =~ "New Region"
    end
  end

  describe "create region" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/torch/regions", region: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/regions/#{id}"

      conn = get(conn, ~p"/torch/regions/#{id}")
      assert html_response(conn, 200) =~ "Region Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/torch/regions", region: @invalid_attrs
      assert html_response(conn, 200) =~ "New Region"
    end
  end

  describe "edit region" do
    setup [:create_region]

    test "renders form for editing chosen region", %{conn: conn, region: region} do
      conn = get(conn, ~p"/torch/regions/#{region}/edit")
      assert html_response(conn, 200) =~ "Edit Region"
    end
  end

  describe "update region" do
    setup [:create_region]

    test "redirects when data is valid", %{conn: conn, region: region} do
      conn = put conn, ~p"/torch/regions/#{region}", region: @update_attrs
      assert redirected_to(conn) == ~p"/torch/regions/#{region}"

      conn = get(conn, ~p"/torch/regions/#{region}")
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, region: region} do
      conn = put conn, ~p"/torch/regions/#{region}", region: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Region"
    end
  end

  describe "delete region" do
    setup [:create_region]

    test "deletes chosen region", %{conn: conn, region: region} do
      conn = delete(conn, ~p"/torch/regions/#{region}")
      assert redirected_to(conn) == "/regions"

      assert_error_sent 404, fn ->
        get(conn, ~p"/torch/regions/#{region}")
      end
    end
  end

  defp create_region(_) do
    region = fixture(:region)
    {:ok, region: region}
  end
end
