defmodule Backend.Collection.CollectionUpdater do
  @moduledoc false
  use Oban.Worker, queue: :hs_collection_updater

  def enqueue(params) do
    create_args(params) |> new() |> Oban.insert()
  end

  @spec create_args(Map.t()) :: Map.t()
  def create_args(params) do
    %{"raw_params" => params, "inserted_at" => NaiveDateTime.utc_now()}
  end
end
