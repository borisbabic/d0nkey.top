defmodule Components.Feed.Tweet do
  @moduledoc "Tweet feed item"
  use Surface.Component

  prop(item, :map, required: true)

  def render(assigns) do
    ~F"""
      <div :if={link = Map.get(@item, :value)} class="card" style="width: calc(2*(var(--decklist-width) - 15px));">
        <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script> 
        <blockquote class="twitter-tweet" data-theme="dark">
          <a href={link}></a> 
        </blockquote>
      </div>
    """
  end
end
