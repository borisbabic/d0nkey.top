defmodule BackendWeb.InvitedPlayerControllerTest do
  use BackendWeb.ConnCase

  alias Backend.MastersTour

  @create_attrs %{
    battletag_full: "some battletag_full",
    official: true,
    reason: "some reason",
    tour_stop: "some tour_stop",
    tournament_id: "some tournament_id",
    tournament_slug: "some tournament_slug",
    type: "some type",
    upstream_time: ~N[2010-04-17 14:00:00]
  }
  @update_attrs %{
    battletag_full: "some updated battletag_full",
    official: false,
    reason: "some updated reason",
    tour_stop: "some updated tour_stop",
    tournament_id: "some updated tournament_id",
    tournament_slug: "some updated tournament_slug",
    type: "some updated type",
    upstream_time: ~N[2011-05-18 15:01:01]
  }
  @invalid_attrs %{
    battletag_full: "wtf",
    official: nil,
    reason: nil,
    tour_stop: nil,
    tournament_id: nil,
    tournament_slug: nil,
    type: nil,
    upstream_time: nil
  }

  def fixture(:invited_player) do
    {:ok, invited_player} = MastersTour.create_invited_player(@create_attrs)
    invited_player
  end

  @spec add_auth(Plug.Conn) :: Plug.Conn
  def add_auth(conn),
    do:
      conn |> Plug.Conn.put_req_header("authorization", "Basic " <> Base.encode64("admin:admin"))

  describe "index" do
    test "lists all invited_player", %{conn: conn} do
      conn = get(conn |> add_auth(), Routes.invited_player_path(conn, :index))
      assert html_response(conn, 200) =~ "Invited player"
    end
  end

  describe "new invited_player" do
    test "renders form", %{conn: conn} do
      conn = get(conn |> add_auth(), Routes.invited_player_path(conn, :new))
      assert html_response(conn, 200) =~ "New Invited player"
    end
  end

  describe "create invited_player" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post conn |> add_auth(), Routes.invited_player_path(conn, :create),
          invited_player: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.invited_player_path(conn, :show, id)

      conn = get(conn, Routes.invited_player_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Invited player Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post conn |> add_auth(), Routes.invited_player_path(conn, :create),
          invited_player: @invalid_attrs

      assert html_response(conn, 200) =~ "New Invited player"
    end
  end

  describe "edit invited_player" do
    setup [:create_invited_player]

    test "renders form for editing chosen invited_player", %{
      conn: conn,
      invited_player: invited_player
    } do
      conn = get(conn |> add_auth(), Routes.invited_player_path(conn, :edit, invited_player))
      assert html_response(conn, 200) =~ "Edit Invited player"
    end
  end

  describe "update invited_player" do
    setup [:create_invited_player]

    test "redirects when data is valid", %{conn: conn, invited_player: invited_player} do
      conn =
        put conn |> add_auth(), Routes.invited_player_path(conn, :update, invited_player),
          invited_player: @update_attrs

      assert redirected_to(conn) == Routes.invited_player_path(conn, :show, invited_player)

      conn = get(conn, Routes.invited_player_path(conn, :show, invited_player))
      assert html_response(conn, 200) =~ "some updated battletag_full"
    end

    test "renders errors when data is invalid", %{conn: conn, invited_player: invited_player} do
      conn =
        put conn |> add_auth(), Routes.invited_player_path(conn, :update, invited_player),
          invited_player: @invalid_attrs

      assert html_response(conn, 200) =~ "Edit Invited player"
    end
  end

  describe "delete invited_player" do
    setup [:create_invited_player]

    test "deletes chosen invited_player", %{conn: conn, invited_player: invited_player} do
      conn = delete(conn |> add_auth(), Routes.invited_player_path(conn, :delete, invited_player))
      assert redirected_to(conn) == Routes.invited_player_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.invited_player_path(conn, :show, invited_player))
      end
    end
  end

  defp create_invited_player(_) do
    invited_player = fixture(:invited_player)
    {:ok, invited_player: invited_player}
  end
end
