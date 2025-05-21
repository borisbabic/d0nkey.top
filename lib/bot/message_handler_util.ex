defmodule Bot.MessageHandlerUtil do
  @moduledoc false
  require Logger
  alias Nostrum.Api
  alias Nostrum.Struct.Message
  alias Nostrum.Struct.User

  @spec get_options(Nostrum.Message.t() | String.t()) :: [String.t()]
  def get_options(%{content: content}), do: get_options(content)

  def get_options(content) do
    get_options(content, :list)
  end

  def options_or_guild_battletags(%{content: content, guild_id: guild_id}) do
    case get_options(content) do
      [_ | _] = battletags -> battletags
      _ -> get_guild_battletags!(guild_id)
    end
  end

  def get_guild_battletags!(guild_id), do: Backend.DiscordBot.get_battletags(guild_id)

  @spec get_options(Nostrum.Message.t() | String.t(), :list) :: [String.t()]
  @spec get_options(Nostrum.Message.t() | String.t(), :string) :: String.t()
  def get_options(%{content: content}, format), do: get_options(content, format)

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

  @spec get_criteria(String.t()) :: {[{String.t() | String.t()}], list()}
  def get_criteria(content) do
    content
    |> get_options()
    |> Enum.reduce({[], []}, fn part, {c, r} ->
      case String.split(part, ":") do
        [p] -> {c, [p | r]}
        crit -> {[List.to_tuple(crit) | c], r}
      end
    end)
  end

  def add_default_criteria(criteria, default) do
    for {key, val} <- default, !List.keymember?(criteria, key, 0), reduce: criteria do
      acc -> [{key, val} | acc]
    end
  end

  @spec reply_or_ignore({:ok, String.t() | list()} | any(), Message.t()) ::
          {:ok, Message.t()} | :ignore
  def reply_or_ignore({:ok, reply}, msg) do
    reply(msg, reply)
  end

  @spec reply(Message.t(), String.t() | list()) :: {:ok, Message.t()}
  def reply(%{channel_id: channel_id, id: id}, options) when is_list(options) do
    with_reference = [{:message_reference, %{message_id: id}} | options]

    Api.Message.create(channel_id, with_reference)
  end

  def reply(msg, content) when is_binary(content) do
    reply(msg, content: content)
  end

  @spec send_message(
          {:ok, String.t()} | {:error, String.t() | atom} | String.t(),
          String.t() | Nostrum.Struct.Message.t()
        ) :: any() | {:ok, Message.t()}
  def send_message(message_tuple, %{channel_id: channel_id}),
    do: send_message(message_tuple, channel_id)

  def send_message({:ok, message}, channel_id) do
    Api.Message.create(channel_id, message)
  end

  def send_message({:error, reason}, channel_id) when is_atom(reason) or is_binary(reason) do
    Logger.warning("Couldn't send discord message to #{channel_id}, reason: #{reason}")
  end

  def send_message(message, channel_id) when is_binary(message) do
    Api.Message.create(channel_id, message)
  end

  def send_message(_, channel_id) do
    Logger.error("Couldn't send discord message to #{channel_id}")
  end

  def send_travolta(channel_id),
    do: Api.Message.create(channel_id, file: "assets/static/images/travolta.gif")

  def send_or_travolta(message, channel_id) do
    if String.replace(message, "`", "") |> String.trim() |> String.first() do
      send_message(message, channel_id)
    else
      send_travolta(channel_id)
    end
  end

  @spec split_discord_tag(String.t()) :: {:ok, {String.t(), String.t()}} | {:error, any()}
  def split_discord_tag(tag) do
    case String.split(tag, "#") do
      [username, discriminator] -> {:ok, {username, discriminator}}
      [username] -> {:ok, {username, "0"}}
      _ -> {:error, :invalid_discord_tag}
    end
  end

  @doc """
  Checks if a user was mentioned in a message
  If no user is specified the current user is checked
  """
  @spec mentioned?(Message.t(), User.t() | nil) :: boolean
  def mentioned?(msg, user \\ nil)

  def mentioned?(msg, nil) do
    id = Bot.UserIdAgent.get()
    mentioned?(msg, id)
  end

  def mentioned?(msg, %{id: id}) do
    mentioned?(msg, id)
  end

  def mentioned?(%{mentions: mentions}, id) when is_binary(id) or is_integer(id) do
    string_id = to_string(id)
    Enum.any?(mentions, &(to_string(&1.id) == string_id))
  end

  def mentioned?(_, _), do: false

  def to_discord_color(hex) when is_binary(hex) do
    hex
    |> String.replace("#", "")
    |> String.replace("0x", "")
    |> Integer.parse(16)
    |> case do
      {num, _} when is_integer(num) -> num
      _ -> nil
    end
  end

  def create_components_message(channel_id, components) when is_list(components) do
    Nostrum.Api.Message.create(channel_id, %{flags: 32_768, components: components})
  end

  def create_components_message(channel_id, %{} = component) do
    create_components_message(channel_id, [component])
  end
end
