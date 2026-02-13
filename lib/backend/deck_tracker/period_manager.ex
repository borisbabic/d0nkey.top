defmodule Hearthstone.DeckTracker.PeriodManager do
  @moduledoc "Manages period \"Business\" Logic. Non CRUD, period creation and updating"
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Period
  alias Hearthstone.DeckTracker.SlowAggregationJob

  def retire_old_periods() do
    cutoff_days = 30
    period_types = ["patch", "release"]
    new_attrs = [auto_aggregate: false, include_in_deck_filters: false]

    cutoff = NaiveDateTime.utc_now() |> Timex.shift(days: -1 * cutoff_days)
    old_criteria = [auto_aggregate: true, period_start_before: cutoff, type: period_types]

    DeckTracker.update_all_periods(old_criteria, set: new_attrs)
  end

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

  def update_brawl_period_start(check_wednesday? \\ true) do
    period = DeckTracker.get_period_by_slug("brawl")

    now = Backend.Blizzard.now()
    start_time = Backend.Blizzard.blizz_o_clock_time()
    wednesday? = Date.day_of_week(now) == 3
    already_started? = :gt == Time.compare(DateTime.to_time(now), start_time)

    if (wednesday? or !check_wednesday?) and already_started? do
      {:ok, period_start} =
        DateTime.new!(DateTime.to_date(now), start_time, now.time_zone)
        |> DateTime.shift_zone("Etc/UTC")

      DeckTracker.update_period(period, %{period_start: period_start})
    end
  end

  defp ensure_period_exists(target, current) do
    slug = archive_slug(target)

    with [] <- DeckTracker.periods([{:slug, [slug]}]) do
      create_archive_period(target, current)
    end
  end

  def any_table_exists?(target) do
    slug = archive_slug(target)

    Enum.any?(target.formats, fn format ->
      table_name = DeckTracker.aggregated_stats_table_name(slug, format)
      match?({:ok, _}, Backend.Repo.table_comment(table_name))
    end)
  end

  def create_archive_period(target, current) do
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
