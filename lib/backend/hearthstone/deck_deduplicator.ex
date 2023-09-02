defmodule Backend.Hearthstone.DeckDeduplicator do
  @moduledoc "Deduplicate decks with the same cards, format, hero and sideboards"
  use Oban.Worker, queue: :deck_deduplicator, unique: [period: 3_600]
  alias Backend.Hearthstone
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
end
