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

  @doc """
  Generate a rank.
  """
  def rank_fixture(attrs \\ %{}) do
    {:ok, rank} =
      attrs
      |> Enum.into(%{
        auto_aggregate: true,
        display: "some display",
        include_in_deck_filters: true,
        include_in_personal_filters: true,
        max_legend_rank: 42,
        max_rank: 42,
        min_legend_rank: 42,
        min_rank: 42,
        slug: "some slug"
      })
      |> Hearthstone.DeckTracker.create_rank()

    rank
  end

  @doc """
  Generate a format.
  """
  def format_fixture(attrs \\ %{}) do
    {:ok, format} =
      attrs
      |> Enum.into(%{
        auto_aggregate: true,
        default: true,
        display: "some display",
        include_in_deck_filters: true,
        include_in_personal_filters: true,
        order_priority: 42,
        value: 42
      })
      |> Hearthstone.DeckTracker.create_format()

    format
  end

  @doc """
  Generate a region.
  """
  def region_fixture(attrs \\ %{}) do
    {:ok, region} =
      attrs
      |> Enum.into(%{
        auto_aggregate: true,
        code: "some code",
        display: "some display"
      })
      |> Hearthstone.DeckTracker.create_region()

    region
  end
end
