defmodule Backend.CollectionManager.CollectionMapRecalculator do
  @moduledoc "Holds calculated collection bags"
  alias Backend.CollectionManager.Collection
  alias Backend.CollectionManager
  alias Backend.Repo
  use Oban.Worker, queue: :hs_collection_map_recalculator, unique: [period: 720]

  def enqueue_all(), do: enqueue_all(NaiveDateTime.utc_now())

  def enqueue_all(%NaiveDateTime{} = cutoff) do
    %{"enqueue_all_before" => cutoff}
    |> new()
    |> Oban.insert()
  end

  def enqueue_all_stale() do
    %{"job" => "enqueue_all_stale"}
    |> new()
    |> Oban.insert()
  end

  def enqueue_stale(%Collection{card_map: nil} = collection), do: do_enqueue_stale(collection)

  def enqueue_stale(%Collection{card_map_updated_at: nil} = collection),
    do: do_enqueue_stale(collection)

  def enqueue_stale(
        %Collection{update_received: update_received, card_map_updated_at: card_map_updated_at} =
          collection
      ) do
    if :lt == NaiveDateTime.compare(card_map_updated_at, update_received) do
      do_enqueue_stale(collection)
    end
  end

  defp do_enqueue_stale(%Collection{} = c), do: stale_args(c) |> new() |> Oban.insert()

  def args(%Collection{id: id, update_received: update_received}, before) do
    %{"id" => id, "update_received" => update_received, "before" => before}
  end

  def stale_args(%Collection{id: id}) do
    %{"id" => id, "job" => "fix_stale"}
  end

  def perform(%Oban.Job{args: %{"id" => id, "job" => "fix_stale"}}) do
    CollectionManager.recalculate_stale_map(id)
  end

  def perform(%Oban.Job{args: %{"job" => "enqueue_all_stale"}}) do
    collections = CollectionManager.stale_or_missing_card_maps()

    Enum.reduce(collections, Ecto.Multi.new(), fn c, multi ->
      args = stale_args(c)
      Oban.insert(multi, Jason.encode(args), new(args))
    end)
    |> Repo.transaction()
  end

  def perform(%Oban.Job{args: %{"enqueue_all_before" => enqueue_all_before}}) do
    collections = CollectionManager.needs_recalculating(enqueue_all_before)

    Enum.reduce(collections, Ecto.Multi.new(), fn c, multi ->
      args = args(c, enqueue_all_before)
      Oban.insert(multi, Jason.encode(args), new(args))
    end)
    |> Repo.transaction()
  end

  def perform(%Oban.Job{
        args: %{"id" => id, "update_received" => update_received, "before" => before}
      }) do
    case CollectionManager.get_for_recalculating(id, update_received, before) do
      %Collection{} = collection ->
        CollectionManager.recalculate_map(collection, update_received, before)
        :ok

      # probaly means it's been updated it the mean time
      _ret ->
        :ok
    end
  end
end
