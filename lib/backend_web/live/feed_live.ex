defmodule BackendWeb.FeedLive do
  @moduledoc false
  alias Backend.Feed.FeedBag
  alias Components.Feed.DeckFeedItem
  alias Components.Feed.LatestHSArticles
  alias Components.Feed.TierList
  alias Components.OmniBar
  use BackendWeb, :surface_live_view

  data(user, :any)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    items = FeedBag.get_current_items()

    ~F"""
      <div>
        <br>
        <div class="level is-mobile">
          <div :if={true} class="level-item">
            <OmniBar id="omni_bar_id"/>
          </div>
          <div class="level-item">
            <FunctionComponents.Ads.below_title mobile_video_floating={true} />
          </div>
          <div :if={false} class="level-item title is-2">Well Met!</div>
        </div>
        <div class="columns is-multiline is-mobile is-narrow is-centered">
          <div :for={item <- items} class="column is-narrow">
            <div :if={item.type == "deck"}>
              <DeckFeedItem item={item}/>
            </div>
            <div :if={item.type == "latest_hs_articles"}>
              <LatestHSArticles />
            </div>
            <div :if={item.type == "tier_list"}>
              <TierList />
            </div>
          </div>
        </div>
      </div>
    """
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
  def is_a_me?(%{user: %{id: 1}}), do: true
  def is_a_me?(_), do: false

  def handle_info({:incoming_result, result}, socket) do
    OmniBar.incoming_result(result, "omni_bar_id")
    {:noreply, socket}
  end
end
