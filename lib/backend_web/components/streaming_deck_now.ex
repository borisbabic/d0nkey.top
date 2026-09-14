defmodule Components.StreamingDeckNow do
  @moduledoc false
  use Surface.Component
  alias Backend.Streaming.StreamingNow
  alias BackendWeb.Router.Helpers, as: Routes
  alias BackendWeb.StreamingNowLive

  prop(deck, :map, required: true)
  data(link, :string)
  data(count, :integer)

  def render(%{count: _, link: _} = assigns) do
    ~F"""
      <a
        :if={@count > 0}
        href={"#{@link}"}
        class="tag is-twitch tw-inline-flex tw-items-center tw-gap-1.5 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-[#9146ff]/20 hover:tw-bg-[#9146ff]/30 tw-text-[#bf94ff] tw-border tw-border-[#9146ff]/40 tw-transition-colors"
        title={"#{@count} streamer(s) currently live with this deck"}
      >
        <span class="tw-w-1.5 tw-h-1.5 tw-rounded-full tw-bg-red-500 tw-animate-pulse"></span>
        <span>Live: {@count}</span>
      </a>
    """
  end

  def render(%{deck: %{deckcode: deckcode}} = assigns) do
    count =
      StreamingNow.streaming_now()
      |> Enum.count(&(&1.deckcode == deckcode))

    link = Routes.live_path(BackendWeb.Endpoint, StreamingNowLive, %{"deckcode" => deckcode})

    assigns |> assign(count: count, link: link) |> render()
  end

  def render(assigns),
    do: ~F"""
    """
end
