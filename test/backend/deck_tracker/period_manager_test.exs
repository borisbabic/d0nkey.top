defmodule Hearthstone.DeckTracker.PeriodManagerTest do
  use Backend.DataCase
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.PeriodManager

  @valid_attrs %{
    auto_aggregate: true,
    display: "some display",
    include_in_deck_filters: true,
    include_in_personal_filters: true,
    order_priority: 42,
    slug: "some-slug",
    type: "patch",
    formats: [1, 2],
    period_start: ~N[2020-01-01 00:00:00]
  }

  def period_fixture(attrs \\ %{}) do
    {:ok, period} =
      attrs
      |> Enum.into(@valid_attrs)
      |> DeckTracker.create_period()

    period
  end

  describe "retire_old_periods/0" do
    test "retires only old periods of correct types" do
      now = NaiveDateTime.utc_now()
      old_cutoff = now |> Timex.shift(days: -31)
      recent_cutoff = now |> Timex.shift(days: -29)

      # Should be retired (patch, old)
      p1 = period_fixture(%{slug: "old-patch", type: "patch", period_start: old_cutoff})
      # Should be retired (release, old)
      p2 = period_fixture(%{slug: "old-release", type: "release", period_start: old_cutoff})

      # Should NOT be retired (too recent)
      p3 = period_fixture(%{slug: "recent-patch", type: "patch", period_start: recent_cutoff})
      # Should NOT be retired (wrong type)
      p4 = period_fixture(%{slug: "old-brawl", type: "brawl", period_start: old_cutoff})
      # Should NOT be retired (wrong type - e.g. rolling)
      p5 =
        period_fixture(%{
          slug: "old-rolling",
          type: "rolling",
          period_start: old_cutoff,
          hours_ago: 720
        })

      PeriodManager.retire_old_periods()

      assert DeckTracker.get_period!(p1.id).auto_aggregate == false
      assert DeckTracker.get_period!(p1.id).include_in_deck_filters == false

      assert DeckTracker.get_period!(p2.id).auto_aggregate == false
      assert DeckTracker.get_period!(p2.id).include_in_deck_filters == false

      assert DeckTracker.get_period!(p3.id).auto_aggregate == true
      assert DeckTracker.get_period!(p3.id).include_in_deck_filters == true

      assert DeckTracker.get_period!(p4.id).auto_aggregate == true
      assert DeckTracker.get_period!(p4.id).include_in_deck_filters == true

      assert DeckTracker.get_period!(p5.id).auto_aggregate == true
      assert DeckTracker.get_period!(p5.id).include_in_deck_filters == true
    end
  end
end
