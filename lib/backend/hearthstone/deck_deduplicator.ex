defmodule Backend.Hearthstone.DeckDeduplicator do
  @moduledoc "Deduplicate decks with the same cards, format, hero and sideboards"
  use Oban.Worker, queue: :deck_deduplicator, unique: [period: 3_600]
  import Ecto.Query

  alias Hearthstone.DeckTracker
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Backend.Repo

  def perform(%Oban.Job{args: %{"ids" => ids}}) do
    Hearthstone.deduplicate_ids(ids)
  end

  def enqueue(args), do: args |> new() |> Oban.insert()

  def enqueue_next(num \\ 1000) do
    Hearthstone.get_duplicated_deck_ids(num, 666_000)
    |> Enum.chunk_every(100)
    |> Enum.map(&insert_all/1)
  end

  def insert_all(list_of_ids) do
    Enum.reduce(list_of_ids, Ecto.Multi.new(), fn arg, multi ->
      Oban.insert(multi, Jason.encode(arg), new(arg))
    end)
    |> Repo.transaction(timeout: 666_000)
  end

  @default_criteria %{
    "period" => "past_week",
    "format" => 2,
    "rank" => "all",
    "opponent_class" => nil,
    "min_games" => 50
  }
  def enqueue_played(num \\ 1000)
  def enqueue_played(num) when is_integer(num), do: enqueue_played(%{"limit" => num})

  def enqueue_played(criteria_override) when is_map(criteria_override) do
    Map.merge(@default_criteria, criteria_override)
    |> Enum.to_list()
    |> enqueue_played()
  end

  def enqueue_played(deck_stats_criteria) when is_list(deck_stats_criteria) do
    deck_stats_criteria
    |> DeckTracker.deck_stats()
    |> Enum.map(& &1.deck_id)
    |> enqueue_duplicates_for_deck_ids()
  end

  def enqueue_duplicates_for_deck_ids(deck_ids) when is_list(deck_ids) do
    query =
      from d in Deck,
        join: d2 in Deck,
        on:
          d.cards == d2.cards and d.format == d2.format and d.hero == d2.hero and
            d.sideboards == d2.sideboards and d.id != d2.id,
        where: d.id in ^deck_ids,
        select: %{ids: [d.id, d2.id]}

    Repo.all(query)
    |> Enum.uniq_by(&Enum.sort(&1.ids))
    |> insert_all()
  end
end
