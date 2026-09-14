defmodule Components.Feed.LatestHSArticles do
  use Surface.Component
  alias Components.Feed.HSArticle

  prop(articles, :list, default: nil)
  prop(num, :integer, default: 5)

  def render(assigns) do
    articles = assigns.articles || get_latest_articles(assigns.num)
    assigns = assign(assigns, articles: articles)

    ~F"""
    <div
      :if={@articles && Enum.any?(@articles)}
      class="card tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-xl tw-shadow-xl hover:tw-border-slate-600/80 tw-transition-all tw-duration-200 tw-overflow-hidden tw-flex tw-flex-col"
      style="width: calc(2*(var(--decklist-width) - 15px));"
    >
      <!-- Header -->
      <div class="tw-flex tw-items-center tw-justify-between tw-px-3.5 tw-py-2.5 tw-border-b tw-border-slate-700/70 tw-bg-[#1b2020]/60">
        <div class="tw-flex tw-items-center tw-gap-2">
          <div class="tw-p-1.5 tw-rounded-lg tw-bg-sky-500/10 tw-text-sky-400 tw-border tw-border-sky-500/20">
            <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
            </svg>
          </div>
          <h3 class="tw-text-xs tw-font-bold tw-text-white tw-tracking-tight">Hearthstone News</h3>
        </div>
        <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[10px] tw-font-semibold tw-uppercase tw-tracking-wider tw-bg-slate-800 tw-text-slate-400 tw-border tw-border-slate-700/80">
          Official
        </span>
      </div>

      <!-- Articles list -->
      <div class="tw-flex tw-flex-col tw-divide-y tw-divide-slate-700/60" :if={latest = Enum.at(@articles, 0)}>
        <div class="tw-p-3">
          <HSArticle article={latest} featured={true} />
        </div>
        <div class="tw-divide-y tw-divide-slate-700/50 is-hidden-mobile">
          <HSArticle :for={a <- Enum.drop(@articles, 1)} article={a} featured={false} />
        </div>
      </div>
    </div>
    """
  end

  defp get_latest_articles(num) do
    Backend.LatestHSArticles.get()
    |> Enum.take(num)
  end
end
