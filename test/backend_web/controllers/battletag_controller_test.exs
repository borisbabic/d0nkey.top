defmodule BackendWeb.BattletagControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Battlenet

  @create_attrs %{
    battletag_full: "some battletag_full",
    battletag_short: "some battletag_short",
    country: "some country",
    priority: 42,
    reported_by: "some reported_by"
  }
  @update_attrs %{
    battletag_full: "some updated battletag_full",
    battletag_short: "some updated battletag_short",
    country: "some updated country",
    priority: 43,
    reported_by: "some updated reported_by"
  }
  @invalid_attrs %{
    battletag_full: nil,
    battletag_short: nil,
    country: nil,
    priority: nil,
    reported_by: nil
  }

  def fixture(:battletag) do
    {:ok, battletag} = Battlenet.create_battletag(@create_attrs)
    battletag
  end

  @spec add_auth(Plug.Conn) :: Plug.Conn
  def add_auth(conn),
    do:
      conn |> Plug.Conn.put_req_header("authorization", "Basic " <> Base.encode64("admin:admin"))

  describe "index" do
    test "lists all battletag_info", %{conn: conn} do
      conn = get(conn |> add_auth(), Routes.battletag_path(conn, :index))
      assert html_response(conn, 200) =~ "Battletag info"
    end
  end

  describe "new battletag" do
    test "renders form", %{conn: conn} do
      conn = get(conn |> add_auth(), Routes.battletag_path(conn, :new))
      assert html_response(conn, 200) =~ "New Battletag"
    end
  end

  describe "create battletag" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn |> add_auth(), Routes.battletag_path(conn, :create), battletag: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.battletag_path(conn, :show, id)

      conn = get(conn, Routes.battletag_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Battletag Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn |> add_auth(), Routes.battletag_path(conn, :create), battletag: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Battletag"
    end
  end

  describe "edit battletag" do
    setup [:create_battletag]

    test "renders form for editing chosen battletag", %{conn: conn, battletag: battletag} do
      conn = get(conn |> add_auth(), Routes.battletag_path(conn, :edit, battletag))
      assert html_response(conn, 200) =~ "Edit Battletag"
    end
  end

  describe "update battletag" do
    setup [:create_battletag]

    test "redirects when data is valid", %{conn: conn, battletag: battletag} do
      conn =
        put(conn |> add_auth(), Routes.battletag_path(conn, :update, battletag),
          battletag: @update_attrs
        )

      assert redirected_to(conn) == Routes.battletag_path(conn, :show, battletag)

      conn = get(conn, Routes.battletag_path(conn, :show, battletag))
      assert html_response(conn, 200) =~ "some updated battletag_full"
    end

    test "renders errors when data is invalid", %{conn: conn, battletag: battletag} do
      conn =
        put conn |> add_auth(), Routes.battletag_path(conn, :update, battletag),
          battletag: @invalid_attrs

      assert html_response(conn, 200) =~ "Edit Battletag"
    end
  end

  describe "delete battletag" do
    setup [:create_battletag]

    test "deletes chosen battletag", %{conn: conn, battletag: battletag} do
      conn = delete(conn |> add_auth(), Routes.battletag_path(conn, :delete, battletag))
      assert redirected_to(conn) == Routes.battletag_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.battletag_path(conn, :show, battletag))
      end
    end
  end

  defp create_battletag(_) do
    battletag = fixture(:battletag)
    {:ok, battletag: battletag}
  end
end
