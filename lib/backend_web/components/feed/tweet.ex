defmodule Components.Feed.Tweet do
  @moduledoc "Tweet feed item"
  use Surface.Component

  prop(item, :map, required: true)

  def render(assigns) do
    ~F"""
    <div
      :if={link = Map.get(@item, :value)}
      class="card tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-xl tw-shadow-xl hover:tw-border-slate-600/80 tw-transition-all tw-duration-200 tw-overflow-hidden tw-p-4 tw-flex tw-flex-col tw-items-center"
      style="width: calc(2*(var(--decklist-width) - 15px));"
    >
      <div class="tw-w-full tw-flex tw-items-center tw-justify-between tw-pb-2 tw-mb-2 tw-border-b tw-border-slate-700/60">
        <div class="tw-flex tw-items-center tw-gap-1.5">
          <div class="tw-p-1 tw-rounded-md tw-bg-slate-800 tw-text-slate-300 tw-border tw-border-slate-700/60">
            <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current" viewBox="0 0 24 24">
              <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 24.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
            </svg>
          </div>
          <span class="tw-text-xs tw-font-bold tw-text-white">Community Post</span>
        </div>
        <a
          href={link}
          target="_blank"
          rel="noopener noreferrer"
          class="tw-inline-flex tw-items-center tw-gap-1 tw-text-xs tw-text-sky-400 hover:tw-text-sky-300 hover:tw-underline tw-transition-colors"
        >
          <span>View on X</span>
          <svg class="tw-w-3 tw-h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
          </svg>
        </a>
      </div>
      <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
      <blockquote class="twitter-tweet" data-theme="dark">
        <a href={link}></a>
      </blockquote>
    </div>
    """
  end
end
