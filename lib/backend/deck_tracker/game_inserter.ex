defmodule Hearthstone.DeckTracker.GameInserter do
  # @moduledoc """
  # Background worker for inserting games
  # """
  @moduledoc "test"
  use Oban.Worker, queue: :hs_game_inserter, unique: [period: 60]
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker
  alias Backend.Repo

  @type api_user_or_id :: Backend.Api.ApiUser.t() | integer()
  @spec enqueue(Map.t(), api_user_or_id) :: any()
  def enqueue(params, api_user_or_id),
    do: create_args(params, api_user_or_id) |> new() |> Oban.insert()

  @spec create_args({Map.t(), api_user_or_id()}) :: Map.t()
  def create_args({params, api_user_or_id}), do: create_args(params, api_user_or_id)
  @spec create_args(Map.t(), api_user_or_id()) :: Map.t()
  def create_args(params, %{id: id}), do: create_args(params, id)

  def create_args(params, api_user_id) do
    %{"raw_params" => params, "api_user_id" => api_user_id}
  end

  @spec enqueue_all([{Map.t()}]) :: term()
  def enqueue_all(tuples) do
    Enum.reduce(tuples, Ecto.Multi.new(), fn arg_raw, multi ->
      args = create_args(arg_raw)
      Oban.insert(multi, Jason.encode(args), new(args))
    end)
    |> Repo.transaction(timeout: 666_000)
  end

  def perform(%Oban.Job{args: %{"raw_params" => raw_params} = args} = job) do
    api_user =
      with id when not is_nil(id) <- Map.get(args, "api_user_id") do
        Backend.Api.get_api_user!(id)
      end

    raw_params
    |> add_inserted_at(job)
    |> GameDto.from_raw_map(api_user)
    |> DeckTracker.handle_game()
  end

  defp add_inserted_at(%{"inserted_at" => inserted_at} = params, _) when not is_nil(inserted_at),
    do: params

  defp add_inserted_at(params, %{inserted_at: %DateTime{} = inserted_at}) do
    Map.put(params, "inserted_at", DateTime.to_iso8601(inserted_at))
  end

  defp add_inserted_at(params, _), do: params
end
