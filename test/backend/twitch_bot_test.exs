defmodule Backend.TwitchBotTest do
  use Backend.DataCase

  alias Backend.TwitchBot

  alias Backend.TwitchBot.TwitchCommand

  @valid_attrs %{user_id: 1, enabled: true, message: "some message", message_regex: true, message_regex_flags: "some message_regex_flags", name: "some name", random_chance: 120.5, response: "some response", sender: "some sender", sender_regex: true, sender_regex_flags: "some sender_regex_flags", type: "some type"}
  @update_attrs %{enabled: false, message: "some updated message", message_regex: false, message_regex_flags: "some updated message_regex_flags", name: "some updated name", random_chance: 456.7, response: "some updated response", sender: "some updated sender", sender_regex: false, sender_regex_flags: "some updated sender_regex_flags", type: "some updated type"}
  @invalid_attrs %{enabled: nil, message: nil, message_regex: nil, message_regex_flags: nil, name: nil, random_chance: nil, response: nil, sender: nil, sender_regex: nil, sender_regex_flags: nil, type: nil}

  describe "#paginate_twitch_commands/1" do
    test "returns paginated list of twitch_commands" do
      for _ <- 1..20 do
        twitch_command_fixture()
      end

      {:ok, %{twitch_commands: twitch_commands} = page} = TwitchBot.paginate_twitch_commands(%{})

      assert length(twitch_commands) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_twitch_commands/0" do
    test "returns all twitch_commands" do
      twitch_command = twitch_command_fixture()
      assert TwitchBot.list_twitch_commands() == [twitch_command]
    end
  end

  describe "#get_twitch_command!/1" do
    test "returns the twitch_command with given id" do
      twitch_command = twitch_command_fixture()
      assert TwitchBot.get_twitch_command!(twitch_command.id) == twitch_command
    end
  end

  describe "#create_twitch_command/1" do
    test "with valid data creates a twitch_command" do
      assert {:ok, %TwitchCommand{} = twitch_command} = TwitchBot.create_twitch_command(@valid_attrs)
      assert twitch_command.enabled == true
      assert twitch_command.message == "some message"
      assert twitch_command.message_regex == true
      assert twitch_command.message_regex_flags == "some message_regex_flags"
      assert twitch_command.name == "some name"
      assert twitch_command.random_chance == 120.5
      assert twitch_command.response == "some response"
      assert twitch_command.sender == "some sender"
      assert twitch_command.sender_regex == true
      assert twitch_command.sender_regex_flags == "some sender_regex_flags"
      assert twitch_command.type == "some type"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TwitchBot.create_twitch_command(@invalid_attrs)
    end
  end

  describe "#update_twitch_command/2" do
    test "with valid data updates the twitch_command" do
      twitch_command = twitch_command_fixture()
      assert {:ok, twitch_command} = TwitchBot.update_twitch_command(twitch_command, @update_attrs)
      assert %TwitchCommand{} = twitch_command
      assert twitch_command.enabled == false
      assert twitch_command.message == "some updated message"
      assert twitch_command.message_regex == false
      assert twitch_command.message_regex_flags == "some updated message_regex_flags"
      assert twitch_command.name == "some updated name"
      assert twitch_command.random_chance == 456.7
      assert twitch_command.response == "some updated response"
      assert twitch_command.sender == "some updated sender"
      assert twitch_command.sender_regex == false
      assert twitch_command.sender_regex_flags == "some updated sender_regex_flags"
      assert twitch_command.type == "some updated type"
    end

    test "with invalid data returns error changeset" do
      twitch_command = twitch_command_fixture()
      assert {:error, %Ecto.Changeset{}} = TwitchBot.update_twitch_command(twitch_command, @invalid_attrs)
      assert twitch_command == TwitchBot.get_twitch_command!(twitch_command.id)
    end
  end

  describe "#delete_twitch_command/1" do
    test "deletes the twitch_command" do
      twitch_command = twitch_command_fixture()
      assert {:ok, %TwitchCommand{}} = TwitchBot.delete_twitch_command(twitch_command)
      assert_raise Ecto.NoResultsError, fn -> TwitchBot.get_twitch_command!(twitch_command.id) end
    end
  end

  describe "#change_twitch_command/1" do
    test "returns a twitch_command changeset" do
      twitch_command = twitch_command_fixture()
      assert %Ecto.Changeset{} = TwitchBot.change_twitch_command(twitch_command)
    end
  end

  def twitch_command_fixture(attrs \\ %{}) do
    {:ok, twitch_command} =
      attrs
      |> Enum.into(@valid_attrs)
      |> TwitchBot.create_twitch_command()

    twitch_command
  end

end
