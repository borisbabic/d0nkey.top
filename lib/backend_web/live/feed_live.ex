defmodule BackendWeb.FeedLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Feed
  alias Components.DeckFeedItem

  def render(assigns) do
    items = Feed.get_current_items()

    ~H"""
      <div class="container">
      <div class="level">
        <div class="level-item title is-2">Well Met!</div>
      </div>
        <div class="columns is-multiline is-mobile is-narrow is-centered">
          <div :for={{ item <- items }}>
            <div :if={{ item.type == "deck" }} class="column is-narrow">
              <DeckFeedItem item={{ item }}/>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
