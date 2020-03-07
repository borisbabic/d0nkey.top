defmodule Backend.DiscordTest do
  use Backend.DataCase

  alias Backend.Discord

  describe "broadcasts" do
    alias Backend.Discord.Broadcast

    @valid_attrs %{
      publish_token: "some publish_token",
      subscribe_token: "some subscribe_token",
      subscribed_urls: []
    }
    @update_attrs %{
      publish_token: "some updated publish_token",
      subscribe_token: "some updated subscribe_token",
      subscribed_urls: []
    }
    @invalid_attrs %{
      publish_token: nil,
      subscribe_token: nil,
      subscribed_urls: nil
    }

    def broadcast_fixture(attrs \\ %{}) do
      {:ok, broadcast} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Discord.create_broadcast()

      broadcast
    end

    test "list_broadcasts/0 returns all broadcasts" do
      broadcast = broadcast_fixture()
      assert Discord.list_broadcasts() == [broadcast]
    end

    test "get_broadcast!/1 returns the broadcast with given id" do
      broadcast = broadcast_fixture()
      assert Discord.get_broadcast!(broadcast.id) == broadcast
    end

    test "create_broadcast/1 with valid data creates a broadcast" do
      assert {:ok, %Broadcast{} = broadcast} = Discord.create_broadcast(@valid_attrs)
      assert broadcast.publish_token == "some publish_token"
      assert broadcast.subscribe_token == "some subscribe_token"
      assert broadcast.subscribed_urls == []
    end

    test "create_broadcast/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Discord.create_broadcast(@invalid_attrs)
    end

    test "update_broadcast/2 with valid data updates the broadcast" do
      broadcast = broadcast_fixture()
      assert {:ok, %Broadcast{} = broadcast} = Discord.update_broadcast(broadcast, @update_attrs)
      assert broadcast.publish_token == "some updated publish_token"
      assert broadcast.subscribe_token == "some updated subscribe_token"
      assert broadcast.subscribed_urls == []
    end

    test "update_broadcast/2 with invalid data returns error changeset" do
      broadcast = broadcast_fixture()
      assert {:error, %Ecto.Changeset{}} = Discord.update_broadcast(broadcast, @invalid_attrs)
      assert broadcast == Discord.get_broadcast!(broadcast.id)
    end

    test "delete_broadcast/1 deletes the broadcast" do
      broadcast = broadcast_fixture()
      assert {:ok, %Broadcast{}} = Discord.delete_broadcast(broadcast)
      assert_raise Ecto.NoResultsError, fn -> Discord.get_broadcast!(broadcast.id) end
    end

    test "change_broadcast/1 returns a broadcast changeset" do
      broadcast = broadcast_fixture()
      assert %Ecto.Changeset{} = Discord.change_broadcast(broadcast)
    end
  end
end
