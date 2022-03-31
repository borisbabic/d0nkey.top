defmodule Components.Feed.HSArticle do
  use BackendWeb, :surface_component
  prop(article, :map, required: true)

  def render(assigns) do
    ~F"""
      <a href={url(@article)} target="_blank">
        <article class="media">
          <div :if={image = image(@article)} class="media-left" style="width: calc(var(--decklist-width)/2);">
            <figure class="image is-2by1">
              <img src={image}>
            </figure>
          </div>
          <div class="media-content">
            <span class="title is-6"> {title(@article)}</span>
          </div>
        </article>

      </a>
    """
  end


  def image(%{"thumbnail" => %{"mimeType"=> <<"image"::binary, _::binary>>, "url" => url}}), do: "https:#{url}"

  def url(%{"blogId" => id}), do: "/hs/article/#{id}"
  def url(%{"defaultUrl" => url}), do: url
  def title(%{"title" => title}), do: title
end
