defmodule Components.Feed.Bluesky do
  @moduledoc "Bluesky feed item"
  use Surface.Component
  alias Backend.Bluesky

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
          <div class="tw-p-1 tw-rounded-md tw-bg-slate-800 tw-text-sky-400 tw-border tw-border-slate-700/60">
            <svg class="tw-w-3.5 tw-h-3.5 tw-fill-current" viewBox="0 0 568 501">
              <path d="M123.121 33.664C188.241 82.553 258.281 181.68 284 234.873c25.719-53.192 95.759-152.32 160.879-201.21C491.866-1.611 568-28.906 568 57.947c0 17.346-9.945 145.713-15.778 166.555-20.275 72.453-94.155 90.933-159.875 79.748C507.222 323.8 536.444 388.56 473.333 453.32c-119.86 122.992-172.272-30.859-185.702-70.281-2.462-7.227-3.614-10.608-3.631-7.733-.017-2.875-1.169.506-3.631 7.733-13.43 39.422-65.842 193.273-185.702 70.281-63.111-64.76-33.89-129.52 80.986-149.071-65.72 11.185-139.6-7.295-159.875-79.748C9.945 203.659 0 75.291 0 57.946 0-28.906 76.135-1.612 123.121 33.664Z"/>
            </svg>
          </div>
          <span class="tw-text-xs tw-font-bold tw-text-white">Community Post</span>
        </div>
        <a
          href={Bluesky.to_web_link(link)}
          target="_blank"
          rel="noopener noreferrer"
          class="tw-inline-flex tw-items-center tw-gap-1 tw-text-xs tw-text-sky-400 hover:tw-text-sky-300 hover:tw-underline tw-transition-colors"
        >
          <span>View on Bluesky</span>
          <svg class="tw-w-3 tw-h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
          </svg>
        </a>
      </div>
      <script async src="https://embed.bsky.app/static/embed.js" charset="utf-8"></script>
      <blockquote class="bluesky-embed" data-bluesky-uri={Bluesky.to_aturi(link)} data-bluesky-embed-color-mode="dark">
        <a href={Bluesky.to_web_link(link)}></a>
      </blockquote>
    </div>
    """
  end

  defdelegate to_web_link(link), to: Bluesky
  defdelegate to_aturi(link), to: Bluesky
end
