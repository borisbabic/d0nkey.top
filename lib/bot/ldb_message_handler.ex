defmodule Bot.LdbMessageHandler do
  @moduledoc false
  alias Nostrum.Api
  alias Backend.Leaderboards
  alias Backend.MastersTour.InvitedPlayer

  def handle_battletags_leaderboard(%{channel_id: channel_id, guild_id: guild_id}) do
    table =
      get_battletags_channel(guild_id)
      |> get_leaderboard_entries()
      |> create_message()

    message =
      if String.trim(table) != "" do
        "```#{table}\n```"
      else
        "Nema nikoga, svi suckamo"
      end

    Api.create_message(channel_id, message)
  end

  @spec get_leaderboard_entries(Nostrum.Struct.Channel.t() | Api.channel_id()) ::
          Leaderboards.categorized_entries()
  def get_leaderboard_entries(%{id: id}) do
    get_leaderboard_entries(id)
  end

  def get_leaderboard_entries(channel_id) do
    Api.get_channel_messages!(channel_id, 1000)
    |> process_battletags()
    |> Leaderboards.get_player_entries()
  end

  @spec create_message(Leaderboards.categorized_entries()) :: String.t()
  def create_message(categorized) do
    categorized
    |> Enum.filter(fn {entries, _, _} -> Enum.any?(entries) end)
    |> Enum.map(fn {entries, region, leaderboard} ->
      body =
        entries
        |> Enum.map_join(
          "\n",
          fn le ->
            "#{String.pad_trailing(to_string(le.rank), 3, [" "])}\t#{le.account_id}"
          end
        )

      "#{String.pad_trailing(to_string(region), 3, [" "])}\t#{leaderboard}\n#{body}"
    end)
    |> Enum.join("\n")
  end

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
    |> Enum.map(&InvitedPlayer.shorten_battletag/1)
  end
end
