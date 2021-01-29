defmodule Bot.MessageHandlerUtil do
  @moduledoc false
  alias Nostrum.Api
  alias Nostrum.Struct.Channel

  @spec get_battletags_channel(Api.guild_id()) :: Api.channel_id()
  def get_battletags_channel(guild_id) do
    Api.get_guild_channels!(guild_id)
    |> Enum.filter(fn %{name: name} -> name == "battletags" end)
    |> Enum.at(0)
  end

  @spec process_battletags([Nostrum.Struct.Message.t()]) :: [String.t()]
  def process_battletags(messages) do
    messages
    |> Enum.map(fn %{content: c} -> c end)
    |> Enum.filter(&Backend.Blizzard.is_battletag?/1)
  end

  @spec get_channel_battletags!(Api.channel_id() | Channel.t()) :: [String.t()]
  def get_channel_battletags!(%Channel{id: id}), do: get_channel_battletags!(id)

  def get_channel_battletags!(channel_id) do
    channel_id
    |> Api.get_channel_messages!(1000)
    |> process_battletags()
  end

  @spec get_guild_battletags!(Api.guild_id()) :: [String.t()]
  def get_guild_battletags!(guild_id) do
    guild_id
    |> get_battletags_channel()
    |> get_channel_battletags!()
  end

  @spec get_options(String.t()) :: [String.t()]
  def get_options(content) do
    get_options(content, :list)
  end

  @spec get_options(String.t(), :list) :: [String.t()]
  @spec get_options(String.t(), :string) :: String.t()
  def get_options(content, :list) do
    content
    |> String.splitter(" ")
    |> Stream.drop(1)
    |> Enum.to_list()
  end

  def get_options(content, :string) do
    content
    |> get_options(:list)
    |> Enum.join(" ")
  end
end
