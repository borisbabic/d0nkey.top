defmodule BackendWeb.StreamingNowLive do
  @moduledoc false
  use BackendWeb, :live_view

  def mount(params, _uri, socket) do
    streaming_now = Backend.Streaming.StreamingNow.streaming_now()
    BackendWeb.Endpoint.subscribe("streaming:hs:streaming_now")
    filter_sort = extract_filter_sort(params)
    {:ok, assign(socket, streaming_now: streaming_now, filter_sort: filter_sort)}
  end

  # def handle_event("inc_temperature", value, socket) do
  # {:noreply, assign(socket, temperature: socket.assigns.temperature + 1)}
  # end
  def handle_info(
        %{topic: "streaming:hs:streaming_now", payload: %{streaming_now: streaming_now}},
        socket
      ) do
    {:noreply, assign(socket, streaming_now: streaming_now)}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, filter_sort: extract_filter_sort(params))}
  end

  def extract_filter_sort(params),
    do: params |> Map.take(["filter_mode", "filter_language", "sort"])

  def filter_sort_streaming(streaming, filter_params),
    do: filter_params |> Enum.reduce(streaming, &filter_sort/2)

  def filter_sort({"filter_mode", mode}, streaming_now),
    do:
      streaming_now
      |> Enum.filter(fn s ->
        Hearthstone.Enums.BnetGameType.game_type_name(s.game_type) == mode
      end)

  def filter_sort({"filter_language", language}, streaming_now),
    do: streaming_now |> Enum.filter(fn s -> s.language == language end)

  def filter_sort({"sort", "newest"}, streaming_now),
    do: streaming_now |> Enum.sort_by(fn s -> s.started_at end, &Timex.after?/2)

  def filter_sort({"sort", "oldest"}, streaming_now),
    do: streaming_now |> Enum.sort_by(fn s -> s.started_at end, &Timex.before?/2)

  def filter_sort({"sort", "most_viewers"}, streaming_now),
    do: streaming_now |> Enum.sort_by(fn s -> s.viewer_count end, &>=/2)

  def filter_sort({"sort", "fewest_viewers"}, streaming_now),
    do: streaming_now |> Enum.sort_by(fn s -> s.viewer_count end, &<=/2)

  def filter_sort(other, carry), do: carry
end
