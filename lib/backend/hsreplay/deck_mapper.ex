defmodule Backend.HSReplay.DeckMapper do
  use Oban.Worker, queue: :hsreplay_deck_mapper, unique: [period: 300]

  alias Backend.Infrastructure.HSReplayCommunicator, as: Api
  alias Backend.HSReplay

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"hsr_deck_id" => hsr_deck_id}}) do
    with {:ok, deck} <- Api.get_deck(hsr_deck_id) do
      HSReplay.insert_map(hsr_deck_id, deck)
    end
    :ok
  end

  def enqueue_jobs(deck_ids), do: Enum.each(deck_ids, &enqueue_job/1)
  def enqueue_job(hsr_deck_id) do
    %{"hsr_deck_id" => hsr_deck_id}
    |> new()
    |> Oban.insert()
  end

end
