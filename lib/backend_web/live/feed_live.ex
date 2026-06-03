defmodule BackendWeb.FeedLive do
  @moduledoc false
  alias Components.Feed.DeckFeedItem
  alias Components.Feed.LatestHSArticles
  alias Components.Feed.TierList
  alias Components.Feed.Tweet
  alias Components.Feed.RevealStreamItem
  alias Components.OmniBar
  use BackendWeb, :surface_live_view

  data(user, :any)
  data(streams, :any)
  data(offset, :integer, default: 0)
  data(end_of_stream?, :boolean, default: false)
  @limit 20

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context() |> stream_items(0)}
  end

  def render(assigns) do
    ~F"""
      <div phx-hook="InfiniteScrollLoaded" id="feed_container">
        <br>
        <div class="level is-mobile">
          <div :if={true} class="level-item">
            <OmniBar id="omni_bar_id"/>
          </div>
          <div class="level-item">
            <FunctionComponents.Ads.below_title />
          </div>
          <div :if={false} class="level-item title is-2">Well Met!</div>
        </div>
        <div
          id="items_viewport"
          phx-update="stream"
          class="columns is-multiline is-mobile is-narrow is-centered"
          phx-viewport-bottom={if @end_of_stream?, do: "", else: "next-page"}>
          <div id={dom_id} :for={{dom_id, item} <- @streams.items} class="column is-narrow">
            <div :if={item.type == "deck"}>
              <DeckFeedItem item={item}/>
            </div>
            <div :if={item.type == "latest_hs_articles"}>
              <LatestHSArticles />
            </div>
            <div :if={item.type == "tweet"}>
              <Tweet item={item}/>
            </div>
            <div :if={item.type == "tier_list"}>
              <TierList />
            </div>
            <div :if={item.type == "reveal_stream"}>
              <RevealStreamItem item={item} />
            </div>
          </div>
        </div>
      </div>
    """
  end

  # def handle_event("previous-page", %{"_overran" => true}, socket) do
  #   %{offset: offset} = socket.assigns

  #   if offset <= (@viewport_size_factor - 1) * @limit do
  #     {:noreply, socket}
  #   else
  #     {:noreply, stream_items(socket, 0)}
  #   end
  # end

  # def handle_event("previous-page", _, socket) do
  #   %{offset: old_offset} = socket.assigns
  #   new_offset = Enum.max([old_offset - @limit, 0])

  #   if new_offset == old_offset do
  #     {:noreply, socket}
  #   else
  #     {:noreply, stream_items(socket, new_offset)}
  #   end
  # end

  def handle_event("next-page", _, socket) do
    %{offset: old_offset} = socket.assigns
    {:noreply, stream_items(socket, old_offset + @limit)}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  defp stream_items(socket, new_offset) when new_offset >= 0 do
    %{offset: curr_offset} = socket.assigns

    fetched_items =
      Backend.Feed.get_current_items(@limit, new_offset)
      |> add_reveal_stream(new_offset)

    handle_offset_stream_scroll(
      socket,
      :items,
      fetched_items,
      new_offset,
      curr_offset,
      nil
    )
  end

  @reveal_streams [
    %{
      start_time: ~N[2026-06-09 21:00:00],
      host: %{
        display: "Rarran",
        link: "https:/www.twitch.tv/rarran"
      },
      guests: [
        %{
          display: "Firebat",
          link: "https://www.twitch.tv/firebat"
        },
        %{
          display: "Regis Killbin",
          link: "https://www.youtube.com/channel/UCbt1SGMrWj5Q7TMXAfmTERQ"
        }
      ]
    }
  ]

  defp add_reveal_stream(items, 0) do
    now = NaiveDateTime.utc_now()

    case Enum.find(@reveal_streams, fn
           %{start_time: start_time} ->
             start_to_show = NaiveDateTime.add(start_time, -4, :hour)
             finish_showing = NaiveDateTime.add(start_time, 1, :hour)
             Util.in_range?(now, {start_to_show, finish_showing})
         end) do
      nil ->
        items

      reveal_stream ->
        [%{type: "reveal_stream", value: reveal_stream}, items]
    end
  end

  defp add_reveal_stream(items, _), do: items

  def handle_info({:incoming_result, result}, socket) do
    OmniBar.incoming_result(result, "omni_bar_id")
    {:noreply, socket}
  end
end
