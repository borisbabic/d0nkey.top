defmodule Components.Feed.LatestHSArticles do
  use Surface.Component
  alias Components.Feed.HSArticle

  def render(assigns) do
    ~F"""
      <div :if={[latest| rest] = get_latest_articles()} class="card" style="width: calc(2*(var(--decklist-width) - 15px));">
        <div class="card-content">
          <div>
            <HSArticle article={latest}/>
          </div>
          <div class="is-hidden-mobile">
            <HSArticle :for={a <- rest} article={a}/>
          </div>
        </div>
      </div>
    """
  end

  defp get_latest_articles() do
    Backend.LatestHSArticles.get()
    |> Enum.take(9)
  end
end
