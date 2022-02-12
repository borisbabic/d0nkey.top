defmodule Components.Feed.LatestHSArticles do
  use Surface.Component
  alias Components.Feed.HSArticle

  def render(assigns) do
    ~F"""
      <div class="card" style="width: calc(2*(var(--decklist-width) + 15px));">
        <div class="card-content">
          <HSArticle :for={a <- get_latest_articles()} article={a}/>
        </div>
      </div>
    """
  end

  defp get_latest_articles() do
    Backend.LatestHSArticles.get()
    |> Enum.take(9)
  end
end
