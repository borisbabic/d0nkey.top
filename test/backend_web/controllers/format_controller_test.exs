defmodule BackendWeb.FormatControllerTest do
  use BackendWeb.ConnCase

  alias Hearthstone.DeckTracker

  @create_attrs %{
    auto_aggregate: true,
    default: true,
    display: "some display",
    include_in_deck_filters: true,
    include_in_personal_filters: true,
    order_priority: 42,
    value: 42
  }
  @update_attrs %{
    auto_aggregate: false,
    default: false,
    display: "some updated display",
    include_in_deck_filters: false,
    include_in_personal_filters: false,
    order_priority: 43,
    value: 43
  }
  @invalid_attrs %{
    auto_aggregate: nil,
    default: nil,
    display: nil,
    include_in_deck_filters: nil,
    include_in_personal_filters: nil,
    order_priority: nil,
    value: nil
  }

  def fixture(:format) do
    {:ok, format} = DeckTracker.create_format(@create_attrs)
    format
  end

  describe "index" do
    test "lists all formats", %{conn: conn} do
      conn = get(conn, ~p"/torch/formats")
      assert html_response(conn, 200) =~ "Formats"
    end
  end

  describe "new format" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/torch/formats/new")
      assert html_response(conn, 200) =~ "New Format"
    end
  end

  describe "create format" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ~p"/torch/formats", format: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/formats/#{id}"

      conn = get(conn, ~p"/torch/formats/#{id}")
      assert html_response(conn, 200) =~ "Format Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ~p"/torch/formats", format: @invalid_attrs
      assert html_response(conn, 200) =~ "New Format"
    end
  end

  describe "edit format" do
    setup [:create_format]

    test "renders form for editing chosen format", %{conn: conn, format: format} do
      conn = get(conn, ~p"/torch/formats/#{format}/edit")
      assert html_response(conn, 200) =~ "Edit Format"
    end
  end

  describe "update format" do
    setup [:create_format]

    test "redirects when data is valid", %{conn: conn, format: format} do
      conn = put conn, ~p"/torch/formats/#{format}", format: @update_attrs
      assert redirected_to(conn) == ~p"/torch/formats/#{format}"

      conn = get(conn, ~p"/torch/formats/#{format}")
      assert html_response(conn, 200) =~ "some updated display"
    end

    test "renders errors when data is invalid", %{conn: conn, format: format} do
      conn = put conn, ~p"/torch/formats/#{format}", format: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Format"
    end
  end

  describe "delete format" do
    setup [:create_format]

    test "deletes chosen format", %{conn: conn, format: format} do
      conn = delete(conn, ~p"/torch/formats/#{format}")
      assert redirected_to(conn) == "/formats"

      assert_error_sent 404, fn ->
        get(conn, ~p"/torch/formats/#{format}")
      end
    end
  end

  defp create_format(_) do
    format = fixture(:format)
    {:ok, format: format}
  end
end
