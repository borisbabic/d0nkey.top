defmodule BackendWeb.FeedItemControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Feed

  @create_attrs %{
    cumulative_decay: 120.5,
    decay_rate: 120.5,
    points: 120.5,
    type: "some type",
    value: "some value"
  }
  @update_attrs %{
    cumulative_decay: 456.7,
    decay_rate: 456.7,
    points: 456.7,
    type: "some updated type",
    value: "some updated value"
  }
  @invalid_attrs %{cumulative_decay: nil, decay_rate: nil, points: nil, type: nil, value: nil}

  def fixture(:feed_item) do
    {:ok, feed_item} = Feed.create_feed_item(@create_attrs)
    feed_item
  end

  describe "index" do
    @describetag :authenticated
    @describetag :feed_items
    test "lists all feed_items", %{conn: conn} do
      conn = get(conn, Routes.feed_item_path(conn, :index))
      assert html_response(conn, 200) =~ "Feed items"
    end
  end

  describe "new feed_item" do
    @describetag :authenticated
    @describetag :feed_items
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.feed_item_path(conn, :new))
      assert html_response(conn, 200) =~ "New Feed item"
    end
  end

  describe "create feed_item" do
    @describetag :authenticated
    @describetag :feed_items
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.feed_item_path(conn, :create), feed_item: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.feed_item_path(conn, :show, id)

      conn = get(conn, Routes.feed_item_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Feed item Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.feed_item_path(conn, :create), feed_item: @invalid_attrs

      assert html_response(conn, 200) =~ "New Feed item"
    end
  end

  describe "edit feed_item" do
    @describetag :authenticated
    @describetag :feed_items
    setup [:create_feed_item]

    test "renders form for editing chosen feed_item", %{conn: conn, feed_item: feed_item} do
      conn = get(conn, Routes.feed_item_path(conn, :edit, feed_item))
      assert html_response(conn, 200) =~ "Edit Feed item"
    end
  end

  describe "update feed_item" do
    @describetag :authenticated
    @describetag :feed_items
    setup [:create_feed_item]

    test "redirects when data is valid", %{conn: conn, feed_item: feed_item} do
      conn = put conn, Routes.feed_item_path(conn, :update, feed_item), feed_item: @update_attrs

      assert redirected_to(conn) == Routes.feed_item_path(conn, :show, feed_item)

      conn = get(conn, Routes.feed_item_path(conn, :show, feed_item))
      assert html_response(conn, 200) =~ "some updated type"
    end

    test "renders errors when data is invalid", %{conn: conn, feed_item: feed_item} do
      conn = put conn, Routes.feed_item_path(conn, :update, feed_item), feed_item: @invalid_attrs

      assert html_response(conn, 200) =~ "Edit Feed item"
    end
  end

  describe "delete feed_item" do
    @describetag :authenticated
    @describetag :feed_items
    setup [:create_feed_item]

    test "deletes chosen feed_item", %{conn: conn, feed_item: feed_item} do
      conn = delete(conn, Routes.feed_item_path(conn, :delete, feed_item))
      assert redirected_to(conn) == Routes.feed_item_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.feed_item_path(conn, :show, feed_item))
      end
    end
  end

  defp create_feed_item(_) do
    feed_item = fixture(:feed_item)
    {:ok, feed_item: feed_item}
  end
end
