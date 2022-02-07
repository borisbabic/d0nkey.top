defmodule BackendWeb.OldBattletagControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Battlenet

  @create_attrs %{old_battletag: "some old_battletag", new_battletag: "new", source: "some source"}
  @update_attrs %{old_battletag: "some updated old_battletag", new_battletag: "new", source: "some updated source"}
  @invalid_attrs %{old_battletag: nil, source: nil}

  def fixture(:old_battletag) do
    {:ok, old_battletag} = Battlenet.create_old_battletag(@create_attrs)
    old_battletag
  end

  describe "index" do
    @describetag :authenticated
    @describetag :old_battletags
    test "lists all old_battletags", %{conn: conn} do
      conn = get conn, Routes.old_battletag_path(conn, :index)
      assert html_response(conn, 200) =~ "Old battletags"
    end
  end

  describe "new old_battletag" do
    @describetag :authenticated
    @describetag :old_battletags
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.old_battletag_path(conn, :new)
      assert html_response(conn, 200) =~ "New Old battletag"
    end
  end

  describe "create old_battletag" do
    @describetag :authenticated
    @describetag :old_battletags
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.old_battletag_path(conn, :create), old_battletag: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.old_battletag_path(conn, :show, id)

      conn = get conn, Routes.old_battletag_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Old battletag Details"
    end

    @describetag :authenticated
    @describetag :old_battletags
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.old_battletag_path(conn, :create), old_battletag: @invalid_attrs
      assert html_response(conn, 200) =~ "New Old battletag"
    end
  end

  describe "edit old_battletag" do
    setup [:create_old_battletag]

    @describetag :authenticated
    @describetag :old_battletags
    test "renders form for editing chosen old_battletag", %{conn: conn, old_battletag: old_battletag} do
      conn = get conn, Routes.old_battletag_path(conn, :edit, old_battletag)
      assert html_response(conn, 200) =~ "Edit Old battletag"
    end
  end

  describe "update old_battletag" do
    setup [:create_old_battletag]

    @describetag :authenticated
    @describetag :old_battletags
    test "redirects when data is valid", %{conn: conn, old_battletag: old_battletag} do
      conn = put conn, Routes.old_battletag_path(conn, :update, old_battletag), old_battletag: @update_attrs
      assert redirected_to(conn) == Routes.old_battletag_path(conn, :show, old_battletag)

      conn = get conn, Routes.old_battletag_path(conn, :show, old_battletag)
      assert html_response(conn, 200) =~ "some updated old_battletag"
    end

    @describetag :authenticated
    @describetag :old_battletags
    test "renders errors when data is invalid", %{conn: conn, old_battletag: old_battletag} do
      conn = put conn, Routes.old_battletag_path(conn, :update, old_battletag), old_battletag: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Old battletag"
    end
  end

  describe "delete old_battletag" do
    setup [:create_old_battletag]

    @describetag :authenticated
    @describetag :old_battletags
    test "deletes chosen old_battletag", %{conn: conn, old_battletag: old_battletag} do
      conn = delete conn, Routes.old_battletag_path(conn, :delete, old_battletag)
      assert redirected_to(conn) == Routes.old_battletag_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, Routes.old_battletag_path(conn, :show, old_battletag)
      end
    end
  end

  defp create_old_battletag(_) do
    old_battletag = fixture(:old_battletag)
    {:ok, old_battletag: old_battletag}
  end
end
