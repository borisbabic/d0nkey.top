defmodule Hearthstone.DeckTracker.GameInserter do
  @moduledoc "Background worker for inserting games"
  use Oban.Worker, queue: :hs_game_inserter, unique: [period: 60]
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker

  def enqueue(params, api_user_id),
    do: %{"raw_params" => params, "api_user_id" => api_user_id} |> new() |> Oban.insert()

  def perform(%Oban.Job{args: %{"raw_params" => raw_params} = args}) do
    api_user =
      with id when not is_nil(id) <- Map.get(args, "api_user_id") do
        Backend.Api.get_api_user!(id)
      end

    raw_params
    |> GameDto.from_raw_map(api_user)
    |> DeckTracker.handle_game()
  end
end
