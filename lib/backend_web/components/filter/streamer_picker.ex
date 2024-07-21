defmodule Components.Filter.StreamerPicker do
  @moduledoc "Component for picking a streamer"
  use BackendWeb, :surface_live_component
  alias Backend.Streaming
  alias Backend.Streaming.Streamer
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput
  alias Components.Dropdown

  prop(title, :string, default: "Search Streamer")
  prop(href_creator, :fun, required: false)
  prop(limit, :integer, default: 10)
  prop(search, :string, default: "")

  def render(assigns) do
    ~F"""
    <span>
      <Dropdown title={@title}>
        <Form for={%{}} as={:streamer} change="search" submit="search">
          <TextInput class="input has-text-black" opts={placeholder: "Search"}/>
        </Form>
        <a class="dropdown-item" href={@href_creator.(streamer)} :for={streamer <- streamers(@search, @limit)}>
          {Streamer.twitch_display(streamer)}<span class="has-text-weight-light"> {Streamer.twitch_login(streamer)}</span>
        </a>
      </Dropdown>
    </span>
    """
  end

  def handle_event("search", %{"streamer" => [search]}, socket),
    do: {:noreply, assign(socket, :search, search)}

  def streamers(search, limit) do
    Streaming.streamers([
      {"search", search},
      {"limit", limit},
      {"order_by", "search_similarity_#{search}"}
    ])
  end
end
