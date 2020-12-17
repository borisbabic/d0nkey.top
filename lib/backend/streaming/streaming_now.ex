defmodule Backend.Streaming.StreamingNow do
  @moduledoc false
  use GenServer

  @type streaming_now :: %{
          user_id: String.t(),
          user_name: String.t(),
          viewer_count: number,
          title: String.t(),
          language: String.t(),
          started_at: NaiveDateTime.t(),
          game_type: number() | nil
        }
  @name :hs_streaming_now
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    partial_state = %{
      hsreplay: Backend.HSReplay.StreamingNow.streaming_now(),
      twitch: Twitch.HearthstoneLive.streams()
    }

    state = partial_state |> Map.put(:streaming_now, create_streaming_now(partial_state))

    ["streaming:hs:twitch_live", "streaming:hs:hsreplay_live"]
    |> Enum.each(fn en -> BackendWeb.Endpoint.subscribe(en) end)

    {:ok, state}
  end

  def streaming_now(), do: Util.gs_call_if_up(@name, :streaming_now, [])

  def handle_call(:streaming_now, _from, state = %{streaming_now: sn}), do: {:reply, sn, state}

  defp update_state(old_state, key, new_val) do
    partially_updated =
      old_state
      |> Map.put(key, new_val)

    updated =
      partially_updated
      |> Map.put(:streaming_now, create_streaming_now(partially_updated))

    BackendWeb.Endpoint.broadcast("streaming:hs:streaming_now", "update", updated)
    updated
  end

  defp create_streaming_now(%{twitch: twitch, hsreplay: hsreplay}) do
    twitch
    |> Enum.map(fn t ->
      {game_type, legend} =
        hsreplay
        |> Enum.find(fn hsr -> to_string(hsr.twitch.id) == to_string(t.user_id) end)
        |> case do
          %{game_type: game_type, legend_rank: legend_rank} -> {game_type, legend_rank}
          _ -> {nil, nil}
        end

      %{
        user_id: t.user_id,
        user_name: t.user_name,
        thumbnail_url: t.thumbnail_url,
        viewer_count: t.viewer_count,
        title: t.title,
        language: t.language,
        started_at: t.started_at,
        legend_rank: legend,
        game_type: game_type
      }
    end)
  end

  def handle_info(%{topic: "streaming:hs:twitch_live", payload: %{streams: twitch}}, state) do
    {:noreply, update_state(state, :twitch, twitch)}
  end

  def handle_info(%{topic: "streaming:hs:hsreplay_live", payload: %{streaming_now: sn}}, state) do
    {:noreply, update_state(state, :hsreplay, sn)}
  end
end
