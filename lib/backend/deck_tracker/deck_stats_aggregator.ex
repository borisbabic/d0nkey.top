defmodule Hearthstone.DeckTracker.DeckStatsAggregator do
  use Oban.Worker, queue: :deck_stats_aggregator, unique: [period: 360_000]

  alias Hearthstone.DeckTracker

  def perform(%Oban.Job{args: %{"start" => start_raw, "class" => class, "rank" => rank}}) do
    {:ok, start} = NaiveDateTime.from_iso8601(start_raw)
    DeckTracker.aggregate_deck_stats(start, class, rank)
  end

  def enqueue_period(%NaiveDateTime{} = start, class, rank) do
    %{start: Util.hour_start(start), class: class, rank: rank}
    |> new()
    |> Oban.insert()
  end

  def enqueue_period(%NaiveDateTime{} = start) do
    for class <- ["ALL" | Backend.Hearthstone.Deck.classes()],
        rank <- ["all", "diamond_to_legend", "legend", "top_legend"] do
      enqueue_period(start, class, rank)
    end
  end

  def enqueue_last_hour() do
    one_hour = Timex.Duration.from_hours(1)

    NaiveDateTime.utc_now()
    |> Timex.subtract(one_hour)
    |> enqueue_period()
  end
end
