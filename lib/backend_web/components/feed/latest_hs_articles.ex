defmodule Components.Feed.LatestHSArticles do
  use Surface.Component
  alias Components.Feed.HSArticle

  def render(assigns) do
    ~F"""
      <div :if={articles = get_latest_articles()} class="card" style="width: calc(2*(var(--decklist-width) - 15px));">
        <div class="card-content" :if={latest = Enum.at(articles, 0)}>
          <div>
            <HSArticle article={latest}/>
          </div>
          <div class="is-hidden-mobile">
            <HSArticle :for={a <- Enum.drop(articles, 1)} article={a}/>
          </div>
        </div>
      </div>
    """
  end

  defp get_latest_articles do
    Backend.LatestHSArticles.get()
    |> Enum.take(9)
  end
end
