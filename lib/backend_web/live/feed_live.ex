defmodule BackendWeb.FeedLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Feed
  alias Components.DeckFeedItem

  def render(assigns) do
    items = Feed.get_current_items()

    ~H"""
      <div class="container">
        <div class="columns is-multiline is-mobile is-narrow">
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
