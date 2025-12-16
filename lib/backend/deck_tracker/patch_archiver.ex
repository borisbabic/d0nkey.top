defmodule Hearthstone.DeckTracker.PatchArchiver do
  @moduledoc "Creates archives of old periods"
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Period
  alias Hearthstone.DeckTracker.SlowAggregationJob

  def archive_latest() do
    latest =
      DeckTracker.periods([
        {:type, ["patch", "release"]},
        {:order_by, {:period_start, :desc}},
        {:not_brawl, true},
        {:format, 2},
        {:limit, 2}
      ])

    with [current, target] <- latest,
         false <- Period.future?(current),
         false <- any_table_exists?(target) do
      ensure_period_exists(target, current)

      for format <- target.formats do
        SlowAggregationJob.enqueue(archive_slug(target), format)
      end
    end
  end

  defp ensure_period_exists(target, current) do
    slug = archive_slug(target)

    with [] <- DeckTracker.periods([{:slug, [slug]}]) do
      create_period(target, current)
    end
  end

  def any_table_exists?(target) do
    slug = archive_slug(target)

    Enum.any?(target.formats, fn format ->
      table_name = DeckTracker.aggregated_stats_table_name(slug, format)
      match?({:ok, _}, Backend.Repo.table_comment(table_name))
    end)
  end

  def create_period(target, current) do
    %{
      auto_aggregate: false,
      display: target.display,
      hours_ago: nil,
      include_in_deck_filters: false,
      include_in_personal_filters: false,
      period_end: current.period_start |> Timex.shift(hours: -1),
      period_start: target.period_start,
      order_priority: -666,
      slug: archive_slug(target),
      type: "archive",
      formats: target.formats
    }
    |> DeckTracker.create_period()
  end

  defp archive_slug(%{slug: slug}) do
    "archive_#{slug}"
  end
end
