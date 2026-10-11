defmodule Components.Filter.StreamerPicker do
  @moduledoc "Component for picking a streamer"
  use BackendWeb, :surface_live_component
  alias Backend.Streaming
  alias Backend.Streaming.Streamer
  alias FunctionComponents.Dropdown

  prop(title, :string, default: "Search Streamer")
  prop(href_creator, :fun, required: false)
  prop(limit, :integer, default: 10)
  prop(search, :string, default: "")

  def render(assigns) do
    ~F"""
    <span>
      <Dropdown.menu title={@title} icon={:streamer}>
        <.form for={%{}} as={:streamer} phx-change="search" phx-submit="search" phx-target={@myself} class="tw-mb-1.5">
          <.search size="sm" value={@search} placeholder="Search streamers" phx-debounce="200" />
        </.form>
        <Dropdown.item
          :for={streamer <- streamers(@search, @limit)}
          href={@href_creator.(streamer)}
          class="tw-group tw-py-1.5"
        >
          <div class="tw-flex tw-flex-col tw-min-w-0 tw-leading-tight">
            <span class="tw-truncate tw-text-sm tw-font-semibold tw-text-slate-100 group-hover:tw-text-white">
              {Streamer.twitch_display(streamer)}
            </span>
            <span
              :if={show_login?(streamer)}
              class="tw-truncate tw-text-[11px] tw-font-normal tw-text-slate-500 group-hover:tw-text-slate-400"
            >
              {Streamer.twitch_login(streamer)}
            </span>
          </div>
        </Dropdown.item>
      </Dropdown.menu>
    </span>
    """
  end

  def handle_event("search", %{"search" => search}, socket) when is_binary(search),
    do: {:noreply, assign(socket, :search, search)}

  def handle_event("search", %{"search" => [search]}, socket),
    do: {:noreply, assign(socket, :search, search)}

  defp show_login?(streamer) do
    login = Streamer.twitch_login(streamer)
    display = Streamer.twitch_display(streamer)
    is_binary(login) and String.downcase(login) != String.downcase(display || "")
  end

  def streamers(search, limit) do
    Streaming.streamers([
      {"search", search},
      {"limit", limit},
      {"order_by", "search_similarity_#{search}"}
    ])
  end
end
