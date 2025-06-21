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

  def args(%Collection{id: id, update_received: update_received}, before) do
    %{"id" => id, "update_received" => update_received, "before" => before}
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
