defmodule Bot.GatewayGuardTest do
  use ExUnit.Case, async: true

  alias Bot.GatewayGuard
  alias Bot.GatewayGuard.LogHandler

  describe "decide/3" do
    test "stops on a fatal close code" do
      assert {{:stop, _}, [100]} = GatewayGuard.decide([], 4004, 100)
      assert {{:stop, _}, _} = GatewayGuard.decide([], 4014, 100)
    end

    test "continues on a normal disconnect" do
      assert {:continue, [100]} = GatewayGuard.decide([], 1000, 100)
      assert {:continue, [100]} = GatewayGuard.decide([], nil, 100)
    end

    test "stops when there are too many disconnects within the window" do
      now = :timer.minutes(20)
      recent = Enum.map(1..30, &(now - &1 * 1000))
      assert {{:stop, _}, _} = GatewayGuard.decide(recent, nil, now)
    end

    test "forgets disconnects outside the window" do
      now = :timer.minutes(60)
      old = Enum.map(1..100, &(&1 * 1000))
      assert {:continue, [^now]} = GatewayGuard.decide(old, nil, now)
    end
  end

  describe "LogHandler.parse/1" do
    test "parses close codes" do
      assert {:disconnected, 4004} =
               LogHandler.parse("Shard websocket closed (errno 4004, reason \"Authentication failed.\")")
    end

    test "parses disconnects without a close code" do
      assert {:disconnected, nil} = LogHandler.parse("Shard websocket closed (unknown reason)")

      assert {:disconnected, nil} =
               LogHandler.parse("Lost complete shard connection. Attempting reconnect.")
    end

    test "ignores other messages" do
      assert :ignore = LogHandler.parse("Will reconnect in response to gateway event")
    end
  end
end
