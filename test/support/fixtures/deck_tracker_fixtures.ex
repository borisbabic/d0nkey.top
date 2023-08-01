defmodule Hearthstone.DeckTrackerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hearthstone.DeckTracker` context.
  """

  @doc """
  Generate a period.
  """
  def period_fixture(attrs \\ %{}) do
    {:ok, period} =
      attrs
      |> Enum.into(%{
        auto_aggregate: true,
        display: "some display",
        hours_ago: 42,
        include_in_deck_filters: true,
        include_in_personal_filters: true,
        period_end: ~N[2023-07-30 23:22:00],
        period_start: ~N[2023-07-30 23:22:00],
        slug: "some slug",
        type: "some type"
      })
      |> Hearthstone.DeckTracker.create_period()

    period
  end
end
