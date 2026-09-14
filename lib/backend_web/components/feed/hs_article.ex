defmodule Components.Feed.HSArticle do
  @moduledoc false
  use BackendWeb, :surface_component
  prop(article, :map, required: true)
  prop(featured, :boolean, default: false)

  def render(%{featured: true} = assigns) do
    ~F"""
    <a
      href={article_url(@article)}
      target="_blank"
      rel="noopener noreferrer"
      class="tw-group tw-block tw-space-y-2.5"
    >
      <div :if={image = image(@article)} class="tw-relative tw-aspect-[2/1] tw-w-full tw-rounded-lg tw-overflow-hidden tw-border tw-border-slate-700/70 tw-bg-[#1b2020]">
        <img
          src={image}
          alt={title(@article)}
          loading="lazy"
          class="tw-w-full tw-h-full tw-object-cover tw-transition-transform tw-duration-300 group-hover:tw-scale-105"
        />
        <div class="tw-absolute tw-inset-0 tw-bg-gradient-to-t tw-from-[#1b2020]/90 tw-via-transparent tw-to-transparent"></div>
        <span class="tw-absolute tw-top-2 tw-left-2 tw-inline-flex tw-items-center tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[10px] tw-font-bold tw-uppercase tw-tracking-wider tw-bg-sky-500/20 tw-text-sky-400 tw-backdrop-blur-sm tw-border tw-border-sky-500/40">
          Latest
        </span>
      </div>
      <div>
        <h4 class="tw-text-xs tw-font-bold tw-text-white group-hover:tw-text-sky-300 tw-transition-colors tw-line-clamp-2 tw-leading-snug">
          {title(@article)}
        </h4>
      </div>
    </a>
    """
  end

  def render(assigns) do
    ~F"""
    <a
      href={article_url(@article)}
      target="_blank"
      rel="noopener noreferrer"
      class="tw-group tw-flex tw-items-center tw-gap-3 tw-p-2.5 hover:tw-bg-slate-800/40 tw-transition-colors"
    >
      <div :if={image = image(@article)} class="tw-relative tw-w-16 tw-h-10 tw-rounded-md tw-overflow-hidden tw-border tw-border-slate-700/70 tw-bg-[#1b2020] tw-shrink-0">
        <img
          src={image}
          alt={title(@article)}
          loading="lazy"
          class="tw-w-full tw-h-full tw-object-cover tw-transition-transform tw-duration-200 group-hover:tw-scale-105"
        />
      </div>
      <div class="tw-flex-1 tw-min-w-0">
        <span class="tw-text-xs tw-font-medium tw-text-slate-200 group-hover:tw-text-sky-300 tw-transition-colors tw-line-clamp-2 tw-leading-tight tw-block">
          {title(@article)}
        </span>
      </div>
      <svg class="tw-w-3.5 tw-h-3.5 tw-text-slate-500 group-hover:tw-text-sky-400 tw-shrink-0 tw-transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
      </svg>
    </a>
    """
  end

  def image(%{
        "thumbnail" => %{"mimeType" => <<"image"::binary, _::binary>>, "url" => "http" <> _ = url}
      }),
      do: url

  def image(%{
        "thumbnail" => %{"mimeType" => <<"image"::binary, _::binary>>, "url" => "//" <> _ = url}
      }),
      do: "https:#{url}"

  def image(%{"thumbnail" => %{"mimeType" => <<"image"::binary, _::binary>>, "url" => url}}),
    do: "https://#{url}"

  def article_url(%{"blogId" => id}), do: "/hs/article/#{id}"
  def article_url(%{"defaultUrl" => url}), do: url
  def title(%{"title" => title}), do: title
end
