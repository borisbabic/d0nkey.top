defmodule BackendWeb.TournamentStreamControllerTest do
  use BackendWeb.ConnCase

  alias Backend.TournamentStreams

  @create_attrs %{
    stream_id: "some stream_id",
    streaming_platform: "some streaming_platform",
    tournament_id: "some tournament_id",
    tournament_source: "some tournament_source"
  }
  @update_attrs %{
    stream_id: "some updated stream_id",
    streaming_platform: "some updated streaming_platform",
    tournament_id: "some updated tournament_id",
    tournament_source: "some updated tournament_source"
  }
  @invalid_attrs %{
    stream_id: nil,
    streaming_platform: nil,
    tournament_id: nil,
    tournament_source: nil
  }

  def fixture(:tournament_stream) do
    {:ok, tournament_stream} = TournamentStreams.create_tournament_stream(@create_attrs)
    tournament_stream
  end

  describe "index" do
    test "lists all tournament_streams", %{conn: conn} do
      conn = get(conn, Routes.tournament_stream_path(conn, :index))
      assert html_response(conn, 200) =~ "Costreams"
    end
  end

  describe "new tournament_stream" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.tournament_stream_path(conn, :new))
      assert html_response(conn, 200) =~ "New Tournament stream"
    end
  end

  describe "create tournament_stream" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post conn, Routes.tournament_stream_path(conn, :create), tournament_stream: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.tournament_stream_path(conn, :show, id)

      conn = get(conn, Routes.tournament_stream_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Tournament stream Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post conn, Routes.tournament_stream_path(conn, :create), tournament_stream: @invalid_attrs

      assert html_response(conn, 200) =~ "New Tournament stream"
    end
  end

  describe "edit tournament_stream" do
    setup [:create_tournament_stream]

    test "renders form for editing chosen tournament_stream", %{
      conn: conn,
      tournament_stream: tournament_stream
    } do
      conn = get(conn, Routes.tournament_stream_path(conn, :edit, tournament_stream))
      assert html_response(conn, 200) =~ "Edit Tournament stream"
    end
  end

  describe "update tournament_stream" do
    setup [:create_tournament_stream]

    test "redirects when data is valid", %{conn: conn, tournament_stream: tournament_stream} do
      conn =
        put conn, Routes.tournament_stream_path(conn, :update, tournament_stream),
          tournament_stream: @update_attrs

      assert redirected_to(conn) == Routes.tournament_stream_path(conn, :show, tournament_stream)

      conn = get(conn, Routes.tournament_stream_path(conn, :show, tournament_stream))
      assert html_response(conn, 200) =~ "some updated stream_id"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      tournament_stream: tournament_stream
    } do
      conn =
        put conn, Routes.tournament_stream_path(conn, :update, tournament_stream),
          tournament_stream: @invalid_attrs

      assert html_response(conn, 200) =~ "Edit Tournament stream"
    end
  end

  describe "delete tournament_stream" do
    setup [:create_tournament_stream]

    test "deletes chosen tournament_stream", %{conn: conn, tournament_stream: tournament_stream} do
      conn = delete(conn, Routes.tournament_stream_path(conn, :delete, tournament_stream))
      assert redirected_to(conn) == Routes.tournament_stream_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.tournament_stream_path(conn, :show, tournament_stream))
      end
    end
  end

  defp create_tournament_stream(_) do
    tournament_stream = fixture(:tournament_stream)
    {:ok, tournament_stream: tournament_stream}
  end
end
