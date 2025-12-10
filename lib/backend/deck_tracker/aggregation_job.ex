defmodule Hearthstone.DeckTracker.AggregationJob do
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Period
  alias Hearthstone.DeckTracker.FastAggregationJob
  alias Hearthstone.DeckTracker.SlowAggregationJob
  import Ecto.Query

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

  def needed() do
    periods = DeckTracker.periods(auto_aggregate: true)
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

        minimum =
          case period do
            %{type: "rolling"} -> 35
            %{type: "patch"} -> 25
            %{type: "release"} -> 5
            _ -> 50
          end

        {period.slug, format_value, minutes_ago, Enum.max([Period.size(period), minimum])}
      end

    potential_formats
    |> Enum.filter(fn {_, _, minutes_ago, size} ->
      1.5 * minutes_ago > size
    end)
    |> Enum.sort_by(fn {_, _, minutes_ago, size} -> minutes_ago / size end, :desc)
  end

  def revive_orphaned() do
    Backend.Repo.update_all(orphaned_query(), set: [state: "available"])
  end

  def orphaned_query() do
    node = Oban.config().node

    from oj in "oban_jobs",
      select: %{id: oj.id, queue: oj.queue, args: oj.args},
      where: fragment("?[1]", oj.attempted_by) != ^node,
      where: oj.queue in ["deck_tracker_aggregator_fast", "deck_tracker_aggregator_slow"],
      where: oj.state == "executing"
  end

  defmacro __using__(opts) do
    queue = Keyword.fetch!(opts, :queue)

    quote do
      use Oban.Worker,
        queue: unquote(queue),
        unique: [
          fields: [:queue, :args],
          states: [:available, :scheduled, :executing, :retryable],
          period: :infinity
        ]

      alias Hearthstone.DeckTracker.StatsAggregator

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
    end
  end
end

defmodule Hearthstone.DeckTracker.FastAggregationJob do
  @moduledoc "Processs Aggregation Job"
  use Hearthstone.DeckTracker.AggregationJob, queue: :deck_tracker_aggregator_fast
end

defmodule Hearthstone.DeckTracker.SlowAggregationJob do
  @moduledoc "Processs Aggregation Job"
  use Hearthstone.DeckTracker.AggregationJob, queue: :deck_tracker_aggregator_slow
end
