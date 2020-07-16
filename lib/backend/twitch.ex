defmodule Backend.Twitch do
  @moduledoc false
  def create_channel_link(<<channel::binary>>), do: "https://www.twitch.tv/#{channel}"
end
