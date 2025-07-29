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
      <Dropdown.menu title={@title}>
        <.form for={%{}} as={:streamer} phx-change="search" phx-submit="search" phx-target={@myself}>
          <input type="text" class="input has-text-black" placeholder="Search"/>
        </.form>
        <Dropdown.item href={@href_creator.(streamer)} :for={streamer <- streamers(@search, @limit)}>
          {Streamer.twitch_display(streamer)}<span class="has-text-weight-light"> {Streamer.twitch_login(streamer)}</span>
        </Dropdown.item>
      </Dropdown.menu>
    </span>
    """
  end

  def handle_event("search", %{"search" => search}, socket) when is_binary(search),
    do: {:noreply, assign(socket, :search, search)}

  def handle_event("search", %{"search" => [search]}, socket),
    do: {:noreply, assign(socket, :search, search)}

  def streamers(search, limit) do
    Streaming.streamers([
      {"search", search},
      {"limit", limit},
      {"order_by", "search_similarity_#{search}"}
    ])
  end
end
