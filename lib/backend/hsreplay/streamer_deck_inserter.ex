defmodule Backend.HSReplay.StreamerDeckInserter do
  use Oban.Worker, queue: :hsreplay_streamer_deck_inserter, unique: [period: 300]

  require Logger
  alias Backend.Infrastructure.HSReplayCommunicator, as: Api
  alias Backend.HSReplay
  alias Backend.Streaming
  alias Backend.Streaming.StreamerDeckInfoDto

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"hsr_deck_id" => hsr_deck_id, "mode" => mode}}) do
    with {:ok, deck_streams} <- Api.get_deck_streams(mode, hsr_deck_id),
        {:ok, deck} <- HSReplay.get_deck(hsr_deck_id),
        results <- Enum.map(deck_streams, & insert_deck_stream(&1, deck)),
        :ok <- ok(results) do
      :ok
    else
      {:error, error} -> {:error, error}
      _other ->
        {:error, "couldn't insert streamer deck"}
    end
  end

  defp ok([]), do: :ok
  defp ok(results) do
    if Enum.any?(results, & :ok == &1) do
      :ok
    else
      {:error, results}
    end
  end
  defp insert_deck_stream(%{"twitch" => %{"user_login" => login}, "rank" => rank, "legend_rank_cohort" => legend_rank}, deck) do
    with streamer = %{id: _id} <- Streaming.get_streamer_by_login(login),
         dto = %StreamerDeckInfoDto{} <- StreamerDeckInfoDto.create(rank || 0, legend_rank || 0, nil),
        {:ok, _} <- Streaming.get_or_create_streamer_deck(deck, streamer, dto) do
      :ok
    else
      nil ->
        Logger.warn("Couldn't get streamer #{login}")
        :ok

      _ ->
        :error
    end
  end
  defp insert_deck_stream(_, _), do: :error

  def enqueue_jobs(mode, hsr_deck_ids), do: Enum.each(hsr_deck_ids, & enqueue_job(mode, &1))
  def enqueue_job(mode, hsr_deck_id) do
    %{"hsr_deck_id" => hsr_deck_id, "mode" => mode}
    |> new()
    |> Oban.insert()
  end
end
