defmodule BackendWeb.LobbyLegendsLive do
  use BackendWeb, :surface_live_view
  alias Backend.LobbyLegends.LobbyLegendsSeason
  alias Components.LiveStreamer
  alias Components.Socials

  @subscriptions ["streaming:hs:streaming_now"]
  data(streaming_now, :map)
  data(season, :any)
  data(user, :any)
  def mount(_params, session, socket) do
    streaming_now = Backend.Streaming.StreamingNow.streaming_now()
    subscribe_to_messages()
    {
    :ok,
    socket
      |> assign_defaults(session)
      |> assign(streaming_now: streaming_now, season: nil)
      |> assign_meta_tags(%{title: "Lobby Legends"})
    }
  end

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div>
        <div class="title is-2">Lobby Legends</div>
        <div class="subtitle is-5 level-left is-mobile">Official Streams: {Socials.twitch("playhearthstone")} | <a href="https://www.youtube.com/hearthstoneesports/live">Youtube</a></div>

        <div class="title is-3">Player Streams</div>
        <div id="live_streamers" class="columns is-multiline">
          <div class="column is-narrow" :for={live <- live_players(@streaming_now, season(@season))}>
            <LiveStreamer live_streamer={live} />
          </div>
        </div>

        <div class="title is-3">Co Streams</div>
        <div id="live_streamers" class="columns is-multiline">
          <div class="column is-narrow" :for={live <- live_other(@streaming_now, season(@season))}>
            <LiveStreamer live_streamer={live} />
          </div>
        </div>

      </div>
    </Context>
    """
  end

  defp live_players(streaming, %{player_streams: player_streams}) do
    live(streaming, player_streams)
  end
  defp live_players(_streaming, _season), do: []
  defp live_other(streaming, %{other_streams: other_streams}) do
    live(streaming, other_streams)
  end
  defp live_other(_streaming, _season), do: []

  defp live(streaming, streams_raw) do
    streams = streams_raw
    |> Map.values()
    |> Enum.filter(& &1)
    |> Enum.map(fn s ->
      String.split(s, "/")
      |> Enum.reverse()
      |> hd()
      |> String.downcase()
    end)
    |> MapSet.new()

    Enum.filter(streaming, fn s ->
      downcase_login = Twitch.Stream.login(s) |> String.downcase()
      MapSet.member?(streams, downcase_login)
    end)
  end
  defp season(slug), do: LobbyLegendsSeason.get_or_current(slug)

  defp subscribe_to_messages() do
    @subscriptions
    |> Enum.each(fn s ->
      # unsub first prevents double subscribes
      BackendWeb.Endpoint.unsubscribe(s)
      BackendWeb.Endpoint.subscribe(s)
    end)
  end

  def handle_info(
        %{topic: "streaming:hs:streaming_now", payload: %{streaming_now: streaming_now}},
        socket
      ) do
    {:noreply, assign(socket, streaming_now: streaming_now)}
  end
end
