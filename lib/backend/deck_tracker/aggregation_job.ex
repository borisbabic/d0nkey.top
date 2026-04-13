defmodule Hearthstone.DeckTracker.AggregationJob do
  @moduledoc "Oban job handling for partitioned stats aggregation"
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Period
  alias Hearthstone.DeckTracker.FastAggregationJob
  alias Hearthstone.DeckTracker.SlowAggregationJob
  import Ecto.Query

  @queues [:deck_tracker_aggregator_fast, :deck_tracker_aggregator_slow]
  @timeouts %{
    deck_tracker_aggregator_fast: :timer.minutes(150),
    deck_tracker_aggregator_slow: :timer.hours(7)
  }
  def enqueue_needed() do
    needed()
    |> Enum.each(fn {period, format, _, size} ->
      if size > 170 do
        SlowAggregationJob.enqueue(period, format)
      else
        FastAggregationJob.enqueue(period, format)
      end
    end)
  end

  def pause_queues() do
    for q <- @queues do
      Oban.pause_queue(queue: q)
    end
  end

  def resume_queues() do
    for q <- @queues do
      Oban.resume_queue(queue: q)
    end
  end

  def needed() do
    periods = DeckTracker.periods(auto_aggregate: true) |> Enum.reject(&Period.future?/1)
    formats = DeckTracker.formats(auto_aggregate: true)

    format_filter = fn format ->
      Enum.any?(formats, &(&1.value == format))
    end

    not_found_time = ~N[2014-03-11T18:00:00]
    now = NaiveDateTime.utc_now()

    potential_formats =
      for %{formats: period_formats} = period <- periods,
          format_value <- Enum.filter(period_formats, format_filter) do
        table_name = DeckTracker.aggregated_stats_table_name(period.slug, format_value)

        inserted_at =
          with {:ok, comment} <- Backend.Repo.table_comment(table_name),
               {:ok, inserted_at} <- NaiveDateTime.from_iso8601(comment) do
            inserted_at
          else
            _ -> not_found_time
          end

        minutes_ago = NaiveDateTime.diff(now, inserted_at, :minute)

        minimum_minutes_ago =
          case period do
            %{type: "rolling"} -> 24
            %{type: "patch"} -> 16
            %{type: "release"} -> 4
            _ -> 32
          end

        {period.slug, format_value, minutes_ago,
         Enum.max([Period.size(period) / 1.5, minimum_minutes_ago])}
      end

    potential_formats
    |> Enum.filter(fn {_, _, minutes_ago, minimum_minutes_ago} ->
      minutes_ago >= minimum_minutes_ago
    end)
    |> Enum.sort_by(fn {_, _, minutes_ago, size} -> minutes_ago / size end, :desc)
  end

  def cancel_orphaned() do
    Oban.cancel_all_jobs(orphaned_query())
  end

  def orphaned_query() do
    node = Oban.config().node

    from oj in "oban_jobs",
      where: fragment("?[1]", oj.attempted_by) != ^node,
      where: oj.queue in ^Enum.map(@queues, &to_string/1),
      where: oj.state == "executing" or oj.state == "available"
  end

  def cancel_old() do
    now = NaiveDateTime.utc_now()
    fast_ms = Map.fetch!(@timeouts, :deck_tracker_aggregator_fast)
    slow_ms = Map.fetch!(@timeouts, :deck_tracker_aggregator_slow)
    fast_cutoff = now |> NaiveDateTime.add(-1.2 * fast_ms, :millisecond)
    slow_cutoff = now |> NaiveDateTime.add(-1.2 * slow_ms, :millisecond)

    from oj in "oban_jobs",
      where:
        (oj.queue == "deck_tracker_aggregator_fast" and oj.inserted_at < ^fast_cutoff) or
          (oj.queue == "deck_tracker_aggregator_slow" and oj.inserted_at < ^slow_cutoff)
  end

  defmacro __using__(opts) do
    queue = Keyword.fetch!(opts, :queue)
    timeout = Map.fetch!(@timeouts, queue)

    quote do
      use Oban.Worker,
        queue: unquote(queue),
        # it got repeatedly stuck with max_attempts: 1
        max_attempts: 2,
        unique: [
          fields: [:queue, :args],
          states: [:available, :scheduled, :executing, :retryable],
          period: :infinity
        ]

      alias Hearthstone.DeckTracker.StatsAggregator

      @impl true
      def perform(%Oban.Job{args: %{"period" => period, "format" => format}}) do
        StatsAggregator.auto_aggregate_period(period, format)
        :ok
      end

      def enqueue(period, format) do
        create_args(period, format)
        |> new()
        |> Oban.insert()
      end

      defp create_args(period, format) do
        %{"period" => period, "format" => format}
      end

      @impl Oban.Worker
      def timeout(_), do: unquote(timeout)
    end
  end
end

defmodule Hearthstone.DeckTracker.FastAggregationJob do
  @moduledoc "Processs Aggregation Job"
  use Hearthstone.DeckTracker.AggregationJob,
    queue: :deck_tracker_aggregator_fast
end

defmodule Hearthstone.DeckTracker.SlowAggregationJob do
  @moduledoc "Processs Aggregation Job"
  use Hearthstone.DeckTracker.AggregationJob,
    queue: :deck_tracker_aggregator_slow
end
