defmodule Backend.DiscordBot do
  @moduledoc false
  alias Backend.Repo
  alias Backend.DiscordBot.GuildBattletags
  import Ecto.Query, warn: false
  require Logger

  alias Nostrum.Api

  @amount_to_fetch 100

  @spec get_battletags(integer()) :: [String.t()]
  def get_battletags(guild_id) do
    with {:ok, gb} <- ensure_guild_battletags(guild_id),
         {_, {:ok, %{battletags: battletags}}} <- {gb, update_battletags(gb)} do
      battletags
    else
      {%{battletags: btags}, _} -> btags
      _ -> []
    end
  end

  def update_all_guilds(sleep \\ 0) do
    with {:ok, guilds} <- Nostrum.Api.get_current_user_guilds() do
      Enum.each(guilds, fn %{id: id} ->
        get_battletags(id)
        Process.sleep(sleep)
      end)
    end
  end

  defp ensure_guild_battletags(guild_id) do
    with {:error, _} <- get_guild_battletags(guild_id) do
      init_guild_battletags(guild_id)
    end
  end

  defp init_guild_battletags(guild_id) do
    with {:ok, %{id: channel_id}} when not is_nil(channel_id) <- get_battletags_channel(guild_id) do
      create_guild_battletags(guild_id, channel_id)
    end
  end

  def get_guild_battletags(guild_id) do
    case Repo.get(GuildBattletags, guild_id) do
      nil -> {:error, :could_not_get_guild_battletats}
      gb -> {:ok, gb}
    end
  end

  @spec update_guild_battletags(GuildBattletags.t(), [String.t()], integer()) ::
          {:ok, GuildBattletags.t()} | {:error, any()}
  def update_guild_battletags(old = %{last_message_id: old_last}, _, new_last)
      when old_last == new_last,
      do: {:ok, old}

  def update_guild_battletags(old, new_battletags, last_message_id) do
    attrs = %{
      battletags: Enum.uniq(old.battletags ++ new_battletags),
      last_message_id: last_message_id
    }

    old
    |> GuildBattletags.changeset(attrs)
    |> Repo.update()
  end

  @spec get_battletags_channel(integer()) :: {:ok, Nostrum.Struct.Channel.t()} | {:error, any()}
  def get_battletags_channel(guild_id) do
    with {:ok, channels} <- Api.get_guild_channels(guild_id),
         [channel | _] <- Enum.filter(channels, &String.starts_with?(&1.name, "battletags")) do
      {:ok, channel}
    else
      error = {:error, _} -> error
      _ -> {:error, :could_not_find_battletags_channel}
    end
  end

  @spec create_guild_battletags(integer(), integer() | nil) ::
          {:ok, GuildBattletags.t()} | {:error, any()}
  def create_guild_battletags(guild_id, channel_id) do
    attrs = %{
      guild_id: guild_id,
      channel_id: channel_id
    }

    %GuildBattletags{}
    |> GuildBattletags.changeset(attrs)
    |> Repo.insert()
  end

  defp update_battletags(%GuildBattletags{last_message_id: last_message_id} = gb) do
    with messages = [%{id: new_last} | _] when new_last != last_message_id <- fetch_messages(gb),
         new_battletags = process_battletags(messages) do
      update_guild_battletags(gb, new_battletags, new_last)
    else
      _ -> {:error, :couldnt_update_battletags}
    end
  end

  @spec fetch_messages(GuildBattletags.t()) :: [Nostrum.Struct.Message.t()]
  defp fetch_messages(%GuildBattletags{channel_id: channel_id, last_message_id: nil}) do
    with {:ok, messages = [_ | _]} <- Api.get_channel_messages(channel_id, @amount_to_fetch),
         {:ok, more_messages} <- do_fetch_initial(channel_id, before_id(messages)) do
      messages ++ more_messages
    else
      _ -> []
    end
  end

  defp fetch_messages(%GuildBattletags{channel_id: channel_id, last_message_id: last_message_id})
       when not is_nil(last_message_id) do
    do_fetch_messages(channel_id, last_message_id)
  end

  defp do_fetch_initial(channel_id, before_id) do
    Process.sleep(1005)

    with {:ok, messages = [_ | _]} <-
           Api.get_channel_messages(channel_id, @amount_to_fetch, {:before, before_id}),
         before_id <- before_id(messages),
         {:ok, newer_messages} <- do_fetch_initial(channel_id, before_id) do
      {:ok, messages ++ newer_messages}
    else
      {:ok, []} ->
        {:ok, []}

      error = {:error, _} ->
        Logger.warn("Error fetching initial: #{inspect(error)}")

      other ->
        Logger.warn("Unknown error fetching initial: #{inspect(other)}")
        {:error, :could_not_fetch_initial_messages}
    end
  end

  defp before_id(messages), do: messages |> Enum.at(-1) |> Map.get(:id)

  defp do_fetch_messages(channel_id, last_message_id) do
    case Api.get_channel_messages(channel_id, @amount_to_fetch, {:after, last_message_id}) do
      {:ok, messages = [%{id: new_last_id} | _]} ->
        do_fetch_messages(channel_id, new_last_id) ++ messages

      _ ->
        []
    end
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
end
