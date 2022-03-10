defmodule BackendWeb.TwitchCommandControllerTest do
  use BackendWeb.ConnCase

  alias Backend.TwitchBot

  @create_attrs %{enabled: true, message: "some message", message_regex: true, message_regex_flags: "some message_regex_flags", name: "some name", random_chance: 120.5, response: "some response", sender: "some sender", sender_regex: true, sender_regex_flags: "some sender_regex_flags", type: "some type"}
  @update_attrs %{enabled: false, message: "some updated message", message_regex: false, message_regex_flags: "some updated message_regex_flags", name: "some updated name", random_chance: 456.7, response: "some updated response", sender: "some updated sender", sender_regex: false, sender_regex_flags: "some updated sender_regex_flags", type: "some updated type"}
  @invalid_attrs %{enabled: nil, message: nil, message_regex: nil, message_regex_flags: nil, name: nil, random_chance: nil, response: nil, sender: nil, sender_regex: nil, sender_regex_flags: nil, type: nil}

  def fixture(:twitch_command) do
    {:ok, twitch_command} = TwitchBot.create_twitch_command(add_user_id(@create_attrs))
    twitch_command
  end

  describe "index" do
    @describetag :authenticated
    @describetag :twitch_commands
    test "lists all twitch_commands", %{conn: conn} do
      conn = get conn, Routes.twitch_command_path(conn, :index)
      assert html_response(conn, 200) =~ "Twitch commands"
    end
  end

  describe "new twitch_command" do
    @describetag :authenticated
    @describetag :twitch_commands
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.twitch_command_path(conn, :new)
      assert html_response(conn, 200) =~ "New Twitch command"
    end
  end

  describe "create twitch_command" do
    @describetag :authenticated
    @describetag :twitch_commands
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.twitch_command_path(conn, :create), twitch_command: add_user_id(@create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.twitch_command_path(conn, :show, id)

      conn = get conn, Routes.twitch_command_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Twitch command Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.twitch_command_path(conn, :create), twitch_command: add_user_id(@invalid_attrs)
      assert html_response(conn, 200) =~ "New Twitch command"
    end
  end

  describe "edit twitch_command" do
    @describetag :authenticated
    @describetag :twitch_commands
    setup [:create_twitch_command]

    test "renders form for editing chosen twitch_command", %{conn: conn, twitch_command: twitch_command} do
      conn = get conn, Routes.twitch_command_path(conn, :edit, twitch_command)
      assert html_response(conn, 200) =~ "Edit Twitch command"
    end
  end

  describe "update twitch_command" do
    @describetag :authenticated
    @describetag :twitch_commands
    setup [:create_twitch_command]

    test "redirects when data is valid", %{conn: conn, twitch_command: twitch_command} do
      conn = put conn, Routes.twitch_command_path(conn, :update, twitch_command), twitch_command: @update_attrs
      assert redirected_to(conn) == Routes.twitch_command_path(conn, :show, twitch_command)

      conn = get conn, Routes.twitch_command_path(conn, :show, twitch_command)
      assert html_response(conn, 200) =~ "some updated message"
    end

    test "renders errors when data is invalid", %{conn: conn, twitch_command: twitch_command} do
      conn = put conn, Routes.twitch_command_path(conn, :update, twitch_command), twitch_command: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Twitch command"
    end
  end

  describe "delete twitch_command" do
    @describetag :authenticated
    @describetag :twitch_commands
    setup [:create_twitch_command]

    test "deletes chosen twitch_command", %{conn: conn, twitch_command: twitch_command} do
      conn = delete conn, Routes.twitch_command_path(conn, :delete, twitch_command)
      assert redirected_to(conn) == Routes.twitch_command_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, Routes.twitch_command_path(conn, :show, twitch_command)
      end
    end
  end

  defp create_twitch_command(_) do
    twitch_command = fixture(:twitch_command)
    {:ok, twitch_command: twitch_command}
  end

  def add_user_id(command) do
    user = create_temp_user()
    Map.put(command, :user_id, user.id)
  end
end
