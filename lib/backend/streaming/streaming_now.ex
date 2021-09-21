defmodule Backend.Streaming.StreamingNow do
  @moduledoc false
  use GenServer
  alias Hearthstone.Enums.BnetGameType

  @type streaming_now :: %{
          user_id: String.t(),
          user_name: String.t(),
          thumbnail_url: String.t(),
          viewer_count: number,
          title: String.t(),
          language: String.t(),
          started_at: NaiveDateTime.t(),
          legend_rank: number() | nil,
          stream_id: String.t() | number,
          deckcode: String.t() | nil,
          game_type: number() | nil
        }
  @name :hs_streaming_now
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    ["streaming:hs:twitch_live", "streaming:hs:hsreplay_live"]
    |> Enum.each(fn en -> BackendWeb.Endpoint.subscribe(en) end)

    {:ok, %{twitch: [], hsreplay: [], streaming_now: []}}
  end

  @spec streaming_now() :: streaming_now()
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

  @spec create_streaming_now(%{
          twitch: [Twitch.Stream.t()],
          hsreplay: [Backend.HSReplay.Streaming.t()]
        }) :: streaming_now()
  defp create_streaming_now(%{twitch: twitch, hsreplay: hsreplay}) do
    twitch
    |> Enum.uniq_by(& &1.id)
    |> Enum.map(fn t ->
      {game_type, legend, deckcode} =
        hsreplay
        |> Enum.find(fn hsr -> to_string(hsr.twitch.id) == to_string(t.user_id) end)
        |> case do
          sn = %{game_type: game_type, legend_rank: legend_rank} ->
            {game_type, legend_rank, sn |> Backend.HSReplay.Streaming.deckcode()}

          _ ->
            {guess_from_title(t.title), nil, nil}
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
        stream_id: t.id,
        deckcode: deckcode,
        game_type: game_type
      }
    end)
  end

  @standard_patterns ["[std]", "[standard]"]
  @duels_patterns ["[duels]", "[duel]"]
  @wild_patterns ["[wild]", "[wld]"]
  @battlegrounds_patterns ["[bg]", "[battlegrounds]", "[bgs]", "[battleground]"]
  @arena_patterns ["[arena]", "[arn]"]
  @classic_patterns ["[classic]"]
  def guess_from_title(title) do
    down = title |> String.downcase()

    cond do
      down |> String.contains?(@standard_patterns) ->
        BnetGameType.ranked_standard()

      down |> String.contains?(@duels_patterns) ->
        BnetGameType.pvpdr()

      down |> String.contains?(@wild_patterns) ->
        BnetGameType.ranked_wild()

      down |> String.contains?(@battlegrounds_patterns) ->
        BnetGameType.battlegrounds()

      down |> String.contains?(@arena_patterns) ->
        BnetGameType.arena()

      down |> String.contains?(@classic_patterns) ->
        BnetGameType.ranked_classic()

      true ->
        nil
    end
  end

  def handle_info(%{topic: "streaming:hs:twitch_live", payload: %{streams: twitch}}, state) do
    {:noreply, update_state(state, :twitch, twitch)}
  end

  def handle_info(%{topic: "streaming:hs:hsreplay_live", payload: %{streaming_now: sn}}, state) do
    {:noreply, update_state(state, :hsreplay, sn)}
  end
end
