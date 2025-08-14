defmodule BackendWeb.StreamingNowLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.LiveStreamer
  alias Backend.DeckInteractionTracker, as: Tracker
  alias FunctionComponents.Dropdown

  @subscriptions ["streaming:hs:streaming_now"]
  data(streaming_now, :map)
  data(filter_sort, :map)
  data(deckcode, :string)

  def mount(_params, session, socket) do
    streaming_now = Backend.Streaming.StreamingNow.streaming_now()
    subscribe_to_messages()

    {:ok,
     assign(socket, streaming_now: streaming_now, page_title: "Streaming Now")
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def handle_params(params, _uri, socket) do
    filter_sort = extract_filter_sort(params)

    {
      :noreply,
      socket
      |> assign(:filter_sort, filter_sort)
    }
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Streaming Now</div>
        <div class="subtitle is-6"><a href={"#{Routes.streaming_path(BackendWeb.Endpoint, :streamer_instructions)}"}>Instructions for streamers</a></div>
        <FunctionComponents.Ads.below_title/>

        <Dropdown.menu title={"Sort"}>
          <Dropdown.item
            selected={@filter_sort["sort"] == val}
            patch={Routes.live_path(BackendWeb.Endpoint, BackendWeb.StreamingNowLive, @filter_sort |> Map.put(:sort,val))}
            :for={{display, val} <- [{"Newest", "newest"}, {"Oldest", "oldest"}, {"Most Viewers", "most_viewers"}, {"Fewest Viewers", "fewest_viewers"}]} >
            {display}
          </Dropdown.item>
        </Dropdown.menu>
        <Dropdown.menu title={"Mode"}>
          <Dropdown.item
            selected={is_nil(@filter_sort["filter_mode"])}
            patch={Routes.live_path(BackendWeb.Endpoint, BackendWeb.StreamingNowLive, @filter_sort |> Map.delete("filter_mode"))} class="dropdown-item" >
            Any
          </Dropdown.item>
          <Dropdown.item
            selected={@filter_sort["filter_mode"] == mode}
            patch={Routes.live_path(BackendWeb.Endpoint, BackendWeb.StreamingNowLive, @filter_sort |> Map.put("filter_mode", mode))}
            :for={mode <- ["Standard", "Battlegrounds", "Mercenaries", "Wild", "Duels",  "Arena", "Tavern Brawl", "Fireside Gathering", "Twist", "Twist", "Unknown"]}>
            {mode}
          </Dropdown.item>
        </Dropdown.menu>
        <Dropdown.menu title={"Language"}>
          <Dropdown.item
            selected={is_nil(@filter_sort["filter_language"])}
            patch={Routes.live_path(BackendWeb.Endpoint, BackendWeb.StreamingNowLive, @filter_sort |> Map.delete("filter_language"))} class="dropdown-item" >
            Any
          </Dropdown.item>
          <Dropdown.item
            selected={@filter_sort["filter_language"] == language}
            patch={Routes.live_path(BackendWeb.Endpoint, BackendWeb.StreamingNowLive, @filter_sort |> Map.put("filter_language", language))}
            :for={language <- @streaming_now |> Enum.map(fn s -> s.language end) |> Enum.uniq() |> Enum.sort()}>
            {language}
          </Dropdown.item>
        </Dropdown.menu>

        <Dropdown.menu :if={Enum.any?(@streaming_now, & &1.legend_rank)} title={"Legend Rank"}>
          <Dropdown.item
            selected={is_nil(@filter_sort["filter_legend"])}
            patch={Routes.live_path(BackendWeb.Endpoint, BackendWeb.StreamingNowLive, @filter_sort |> Map.delete("filter_legend"))} class="dropdown-item" >
            Any
          </Dropdown.item>
          <Dropdown.item
            selected={@filter_sort["filter_legend"] == legend}
            patch={Routes.live_path(BackendWeb.Endpoint, BackendWeb.StreamingNowLive, @filter_sort |> Map.put("filter_legend", legend))}
            :for={legend <- [100, 200, 500, 1000, 5000]}>
            {legend}
          </Dropdown.item>
        </Dropdown.menu>

        <div class="columns is-multiline">
          <div class="column is-narrow" :for={ls <- @streaming_now |> filter_sort_streaming(@filter_sort)} >
            <div>
              <LiveStreamer live_streamer={ls}>
                <Components.ExpandableDecklist :if={ls.deckcode} id={"deck_#{ls.stream_id}_#{ls.deckcode}"} show_cards={false} deck={ls.deckcode |> Backend.Hearthstone.Deck.decode!()} />
              </LiveStreamer>
            </div>
          </div>
        </div>
      </div>
    """
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_info(
        %{topic: "streaming:hs:streaming_now", payload: %{streaming_now: streaming_now}},
        socket
      ) do
    {:noreply, assign(socket, streaming_now: streaming_now)}
  end

  defp subscribe_to_messages() do
    @subscriptions
    |> Enum.each(fn s ->
      # unsub first prevents double subscribes
      BackendWeb.Endpoint.unsubscribe(s)
      BackendWeb.Endpoint.subscribe(s)
    end)
  end

  def extract_filter_sort(params),
    do:
      params
      |> Map.take([
        "filter_mode",
        "filter_language",
        "sort",
        "filter_legend",
        "deckcode",
        "for_tournament",
        "tournament",
        "for_tournaments",
        "tournaments"
      ])

  def filter_sort_streaming(streaming, filter_params),
    do: filter_params |> Enum.reduce(streaming, &filter_sort/2)

  def filter_sort({"filter_mode", mode}, streaming_now),
    do:
      streaming_now
      |> Enum.filter(fn s ->
        Hearthstone.Enums.BnetGameType.game_type_name(s.game_type) == mode
      end)

  def filter_sort({"tournaments", tournaments}, streaming_now),
    do: filter_sort({"for_tournaments", tournaments}, streaming_now)

  def filter_sort({"for_tournaments", tournaments}, streaming_now) when is_list(tournaments) do
    tournament_streams =
      Enum.flat_map(tournaments, &streams_for_tournament_string/1) |> MapSet.new()

    streaming_now
    |> Enum.filter(fn s ->
      MapSet.member?(tournament_streams, to_string(s.user_id))
    end)
  end

  def filter_sort({"tournament", tournament_string}, streaming_now),
    do: filter_sort({"for_tournament", tournament_string}, streaming_now)

  def filter_sort({"for_tournament", tournament_string}, streaming_now) do
    tournament_streams = streams_for_tournament_string(tournament_string) |> MapSet.new()

    streaming_now
    |> Enum.filter(fn s ->
      MapSet.member?(tournament_streams, to_string(s.user_id))
    end)
  end

  def filter_sort({"filter_language", language}, streaming_now),
    do: streaming_now |> Enum.filter(fn s -> s.language == language end)

  def filter_sort({"filter_legend", legend}, streaming_now),
    do:
      streaming_now
      |> Enum.filter(fn s ->
        s.legend_rank && s.legend_rank > 0 && s.legend_rank <= legend |> Util.to_int_or_orig()
      end)

  def filter_sort({"deckcode", deckcode}, streaming_now) when is_binary(deckcode),
    do: streaming_now |> Enum.filter(&(&1.deckcode == deckcode))

  def filter_sort({"sort", "newest"}, streaming_now),
    do: streaming_now |> Enum.sort_by(fn s -> s.started_at end, &Timex.after?/2)

  def filter_sort({"sort", "oldest"}, streaming_now),
    do: streaming_now |> Enum.sort_by(fn s -> s.started_at end, &Timex.before?/2)

  def filter_sort({"sort", "most_viewers"}, streaming_now),
    do: streaming_now |> Enum.sort_by(fn s -> s.viewer_count end, &>=/2)

  def filter_sort({"sort", "fewest_viewers"}, streaming_now),
    do: streaming_now |> Enum.sort_by(fn s -> s.viewer_count end, &<=/2)

  def filter_sort(_other, carry), do: carry

  defp streams_for_tournament_string(tournament_string) do
    [source, id] = String.split(tournament_string, "|")

    Backend.TournamentStreams.get_for_tournament({source, id})
    |> Enum.map(& &1.stream_id)
  end
end
