defmodule Backend.BlizzardTest do
  use ExUnit.Case, async: true
  alias Backend.Blizzard

  # 2026-10-13 is a Tuesday
  defp pacific(naive), do: DateTime.from_naive!(naive, "US/Pacific")

  describe "next_blizz_o_clock/2" do
    test "returns today when blizz o clock hasn't passed" do
      now = pacific(~N[2026-10-13 09:00:00])
      assert Blizzard.next_blizz_o_clock(nil, now) == pacific(~N[2026-10-13 10:00:00])
    end

    test "returns tomorrow when blizz o clock has passed" do
      now = pacific(~N[2026-10-13 11:00:00])
      assert Blizzard.next_blizz_o_clock(nil, now) == pacific(~N[2026-10-14 10:00:00])
    end

    test "returns the next occurrence of the specified day" do
      now = pacific(~N[2026-10-13 11:00:00])
      assert Blizzard.next_blizz_o_clock(4, now) == pacific(~N[2026-10-15 10:00:00])
      assert Blizzard.next_blizz_o_clock(1, now) == pacific(~N[2026-10-19 10:00:00])
    end

    test "returns today for the current day when blizz o clock hasn't passed" do
      now = pacific(~N[2026-10-13 09:00:00])
      assert Blizzard.next_blizz_o_clock(2, now) == pacific(~N[2026-10-13 10:00:00])
    end

    test "returns next week for the current day when blizz o clock has passed" do
      now = pacific(~N[2026-10-13 11:00:00])
      assert Blizzard.next_blizz_o_clock(2, now) == pacific(~N[2026-10-20 10:00:00])
    end

    test "uses the pacific date for non pacific datetimes" do
      # 2026-10-14 03:00 UTC is still Tuesday 2026-10-13 in pacific
      now = DateTime.from_naive!(~N[2026-10-14 03:00:00], "Etc/UTC")
      assert Blizzard.next_blizz_o_clock(3, now) == pacific(~N[2026-10-14 10:00:00])
    end
  end
end
