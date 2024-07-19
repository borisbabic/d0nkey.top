defmodule BackendWeb.StreamerPickerLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout
  alias Components.Filter.StreamerPicker
  data(base_url, :string)
  data(href_creator, :fun)

  def mount(_params, %{"base_url" => base_url}, socket) do
    {:ok, assign(socket, base_url: base_url, href_creator: create_href_creator(base_url))}
  end

  def render(assigns) do
    ~F"""
    <StreamerPicker href_creator={@href_creator} id="streamer_picker" />
    """
  end

  def create_href_creator(base_url) do
    fn
      %{twitch_id: twitch_id} when is_integer(twitch_id) or is_binary(twitch_id) ->
        Util.add_query_param(base_url, "twitch_id", twitch_id)

      _ ->
        nil
    end
  end
end
