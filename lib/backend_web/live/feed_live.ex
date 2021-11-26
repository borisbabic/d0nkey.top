defmodule BackendWeb.FeedLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Feed
  alias Components.DeckFeedItem
  alias Components.OmniBar
  import BackendWeb.LiveHelpers

  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    items = Feed.get_current_items()

    ~F"""
    <Context put={user: @user} >
      <div class="container">
        <br>
        <div class="level is-mobile">
          <div :if={true} class="level-item">
            <OmniBar id="omni_bar_id"/>
          </div>
          <div :if={false} class="level-item title is-2">Well Met!</div>
        </div>
        <div class="columns is-multiline is-mobile is-narrow is-centered">
          <div :for={item <- items} :if={item.type == "deck"} class="column is-narrow">
            <DeckFeedItem item={item}/>
          </div>
        </div>
      </div>
    </Context>
    """
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def handle_info({:incoming_result, result}, socket) do
    OmniBar.incoming_result(result, "omni_bar_id")
    {:noreply, socket}
  end
end
