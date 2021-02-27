defmodule BackendWeb.FeedLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Feed
  alias Components.DeckFeedItem
  import BackendWeb.LiveHelpers

  data(user, :any)

  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    items = Feed.get_current_items()

    ~H"""
    <Context put={{ user: @user }} >
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
    </Context>
    """
  end
end
