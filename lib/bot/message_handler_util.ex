defmodule Bot.MessageHandlerUtil do
  @moduledoc false
  require Logger
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
    |> Enum.flat_map(fn %{content: c} ->
      case Backend.Battlenet.Battletag.extract_battletag(c) do
        {:ok, btag} -> [btag]
        _ -> []
      end
    end)
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

  @spec send_message({:ok, String.t()} | {:error, String.t() | atom} | String.t(), String.t() | Nostrum.Struct.Message.t()) :: any() | {:ok, Message.t()}
  def send_message(message_tuple, %{channel_id: channel_id}), do: send_message(message_tuple, channel_id)
  def send_message({:ok, message}, channel_id) do
    Api.create_message(channel_id, message)
  end
  def send_message({:error, reason}, channel_id) when is_atom(reason) or is_binary(reason) do
    Logger.warn("Couldn't send discord message to #{channel_id}, reason: #{reason}")
  end
  def send_message(message, channel_id) when is_binary(message) do
    Api.create_message(channel_id, message)
  end
  def send_message(_, channel_id) do
    Logger.error("Couldn't send discord message to #{channel_id}")
  end

  def send_travolta(channel_id), do:
    Api.create_message(channel_id, file: "assets/static/images/travolta.gif")

  def send_or_travolta(message, channel_id) do
    if String.replace(message, "`", "") |> String.trim() |> String.first() do
      send_message(message, channel_id)
    else
      send_travolta(channel_id)
    end
  end
end
