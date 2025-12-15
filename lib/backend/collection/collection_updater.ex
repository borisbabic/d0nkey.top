defmodule Backend.CollectionManager.CollectionUpdater do
  @moduledoc false
  use Oban.Worker, queue: :hs_collection_updater
  alias Backend.CollectionManager.CollectionDto
  alias Backend.CollectionManager

  def enqueue(params) do
    create_args(params) |> new() |> Oban.insert()
  end

  @spec create_args(map()) :: map()
  def create_args(params) do
    %{"raw_params" => params, "inserted_at" => NaiveDateTime.utc_now()}
  end

  def perform(%Oban.Job{args: %{"raw_params" => raw_params, "inserted_at" => received}}) do
    with {:ok, dto} <- CollectionDto.from_raw_map(raw_params, received) do
      result = CollectionManager.upsert_collection(dto)

      with {:ok, collection} <- result do
        Backend.UserManager.init_current_collection(collection)
      end

      result
    end
  end
end
