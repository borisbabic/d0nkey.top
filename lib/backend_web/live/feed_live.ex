defmodule BackendWeb.FeedLive do
  @moduledoc false
  alias Components.Feed.DeckFeedItem
  alias Components.Feed.LatestHSArticles
  alias Components.Feed.TierList
  alias Components.Feed.Tweet
  alias Components.OmniBar
  use BackendWeb, :surface_live_view

  data(user, :any)
  data(streams, :any)
  data(offset, :integer, default: 0)
  data(end_of_stream?, :boolean, default: false)
  @limit 20
  @viewport_size_factor 4

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context() |> stream_items(0)}
  end

  def render(assigns) do
    ~F"""
      <div>
        <br>
        <div class="level is-mobile">
          <div :if={true} class="level-item">
            <OmniBar id="omni_bar_id"/>
          </div>
          <div class="level-item">
            <FunctionComponents.Ads.below_title mobile_video_mode={:floating} />
          </div>
          <div :if={false} class="level-item title is-2">Well Met!</div>
        </div>
        <div
          id="items_viewport"
          phx-update="stream"
          class="columns is-multiline is-mobile is-narrow is-centered"
          phx-viewport-top="previous-page"
          phx-viewport-bottom={!@end_of_stream? && "next-page"}>
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
          </div>
        </div>
      </div>
    """
  end

  def handle_event("previous-page", %{"_overran" => true}, socket) do
    %{offset: offset} = socket.assigns
    IO.inspect({offset, @viewport_size_factor, @limit})

    if offset <= (@viewport_size_factor - 1) * @limit do
      {:noreply, socket}
    else
      {:noreply, stream_items(socket, 0)}
    end
  end

  def handle_event("previous-page", _, socket) do
    %{offset: old_offset} = socket.assigns
    new_offset = Enum.max([old_offset - @limit, 0])

    if new_offset == old_offset do
      {:noreply, socket}
    else
      {:noreply, stream_items(socket, new_offset)}
    end
  end

  def handle_event("next-page", _, socket) do
    %{offset: old_offset} = socket.assigns
    {:noreply, stream_items(socket, old_offset + @limit)}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  defp stream_items(socket, new_offset) when new_offset >= 0 do
    %{offset: curr_offset} = socket.assigns
    fetched_items = Backend.Feed.get_current_items(@limit, new_offset)

    {items, at, stream_limit} =
      if new_offset >= curr_offset do
        {fetched_items, -1, @limit * @viewport_size_factor * -1}
      else
        {Enum.reverse(fetched_items), 0, @limit * @viewport_size_factor}
      end

    case items do
      [] ->
        assign(socket, end_of_stream?: true)

      [_ | _] = items ->
        socket
        |> assign(end_of_stream?: false)
        |> assign(:offset, new_offset)
        |> stream(:items, items, at: at, limit: stream_limit)
    end
  end

  def handle_info({:incoming_result, result}, socket) do
    OmniBar.incoming_result(result, "omni_bar_id")
    {:noreply, socket}
  end
end
