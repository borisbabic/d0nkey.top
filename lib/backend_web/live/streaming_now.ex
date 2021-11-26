defmodule BackendWeb.StreamingNowLive do
  @moduledoc false
  use Surface.LiveView
  import BackendWeb.LiveHelpers
  alias Components.LiveStreamer
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Surface.Components.LivePatch
  alias BackendWeb.Router.Helpers, as: Routes
  @subscriptions ["streaming:hs:streaming_now"]
  data(streaming_now, :map)
  data(filter_sort, :map)
  data(deckcode, :string)

  def mount(_params, session, socket) do
    streaming_now = Backend.Streaming.StreamingNow.streaming_now()
    subscribe_to_messages()
    {:ok, assign(socket, streaming_now: streaming_now) |> assign_defaults(session)}
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
    instructions_link = Routes.streaming_path(BackendWeb.Endpoint, :streamer_instructions)

    ~F"""
    <Context put={user: @user} >
      <div class="container">
        <div class="title is-2">Streaming Now</div>
        <div class="subtitle is-6"><a href={"#{instructions_link}"}>Instructions for streamers</a></div>

        <div class="dropdown is-hoverable">
            <div class="dropdown-trigger"><button aria-haspopup="true" aria-controls="dropdown-menu" class="button" type="button">Sort</button></div>
            <div class="dropdown-menu" role="menu">
                <div class="dropdown-content">
                  <div :for={{display, val} <- [{"Newest", "newest"}, {"Oldest", "oldest"}, {"Most Viewers", "most_viewers"}, {"Fewest Viewers", "fewest_viewers"}]}>
                      <LivePatch
                        class={"#{"dropdown-item " <> if @filter_sort["sort"] == val, do: "is-active", else: "" }"}
                        to={"#{Routes.live_path(@socket, BackendWeb.StreamingNowLive, @filter_sort |> Map.put(:sort,val))}"}
                        >
                      {display}
                      </LivePatch>
                  </div>
                </div>
            </div>
        </div>

        <div class="dropdown is-hoverable">
            <div class="dropdown-trigger"><button aria-haspopup="true" aria-controls="dropdown-menu" class="button" type="button">Mode</button></div>
            <div class="dropdown-menu" role="menu">
                <div class="dropdown-content">
                    <LivePatch to={"#{Routes.live_path(@socket, BackendWeb.StreamingNowLive, @filter_sort |> Map.delete("filter_mode"))}"} class="dropdown-item" >
                      Any
                    </LivePatch>
                    <div :for={m <- ["Standard", "Battlegrounds", "Mercenaries", "Wild", "Duels",  "Arena", "Tavern Brawl", "Fireside Gathering", "Classic", "Unknown"]}>
                      <LivePatch
                        class={"#{"dropdown-item " <> if @filter_sort["filter_mode"] == m, do: "is-active", else: "" }"}
                        to={"#{Routes.live_path(@socket, BackendWeb.StreamingNowLive, @filter_sort |> Map.put("filter_mode", m))}"}
                        >
                      {m}
                      </LivePatch>
                    </div>
                </div>
            </div>
        </div>

        <div class="dropdown is-hoverable">
            <div class="dropdown-trigger"><button aria-haspopup="true" aria-controls="dropdown-menu" class="button" type="button">Language</button></div>
            <div class="dropdown-menu" role="menu">
                <div class="dropdown-content">
                  <div class="dropdown-content">
                      <LivePatch to={"#{Routes.live_path(@socket, BackendWeb.StreamingNowLive, @filter_sort |> Map.delete("filter_language"))}"} class="dropdown-item" >
                        Any
                      </LivePatch>
                      <div :for={l <- @streaming_now |> Enum.map(fn s -> s.language end) |> Enum.uniq() |> Enum.sort()}>
                        <LivePatch
                          class={"#{ "dropdown-item " <> if @filter_sort["filter_language"] == l, do: "is-active", else: "" }"}
                          to={"#{Routes.live_path(@socket, BackendWeb.StreamingNowLive, @filter_sort |> Map.put("filter_language", l))}"}
                          >
                        {l}
                        </LivePatch>
                      </div>
                  </div>
                </div>
            </div>
        </div>

        <div class="dropdown is-hoverable">
            <div class="dropdown-trigger"><button aria-haspopup="true" aria-controls="dropdown-menu" class="button" type="button">Legend Rank</button></div>
            <div class="dropdown-menu" role="menu">
                <div class="dropdown-content">
                      <LivePatch to={"#{Routes.live_path(@socket, BackendWeb.StreamingNowLive, @filter_sort |> Map.delete("filter_legend"))}"} class="dropdown-item" >
                        Any
                      </LivePatch>
                      <div :for={l <- [100, 200, 500, 1000, 5000]}>
                        <LivePatch
                        class={"#{"dropdown-item " <> if @filter_sort["filter_legend"] == to_string(l), do: "is-active", else: "" }"}
                          to={"#{Routes.live_path(@socket, BackendWeb.StreamingNowLive, @filter_sort |> Map.put("filter_legend", l))}"}
                          >
                        {l}
                        </LivePatch>
                      </div>
                </div>
            </div>
        </div>




        <div class="columns is-multiline">
          <div class="column is-narrow" :for={ls <- @streaming_now |> filter_sort_streaming(@filter_sort)} >
            <div>
              <LiveStreamer live_streamer={ls}>
                <Components.ExpandableDecklist :if={ls.deckcode} id={"deck_#{ls.stream_id}_#{ls.deckcode}"} show_cards={false} deck={ls.deckcode |> Backend.Hearthstone.Deck.decode!()} guess_archetype={true}/>
              </LiveStreamer>
            </div>
          </div>
        </div>
      </div>
    </Context>
    """
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("toggle_cards", params, socket) do
    Components.ExpandableDecklist.toggle_cards(params)

    {
      :noreply,
      socket
    }
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
      params |> Map.take(["filter_mode", "filter_language", "sort", "filter_legend", "deckcode"])

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
end
