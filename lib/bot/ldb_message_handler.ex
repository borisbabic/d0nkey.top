defmodule Bot.LdbMessageHandler do
  @moduledoc false
  alias Nostrum.Api
  alias Backend.Leaderboards
  alias Backend.MastersTour.InvitedPlayer
  import Bot.MessageHandlerUtil

  def handle_battletags_leaderboard(%{channel_id: channel_id, guild_id: guild_id}) do
    table =
      get_battletags_channel(guild_id)
      |> get_leaderboard_entries()
      |> create_message()

    message =
      if String.trim(table) != "" do
        "```\n#{table}\n```"
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
    get_channel_battletags!(channel_id)
    |> Enum.map(&InvitedPlayer.shorten_battletag/1)
    |> Leaderboards.get_player_entries()
  end

  @spec create_message(Leaderboards.categorized_entries()) :: String.t()
  def create_message(categorized) do
    categorized
    |> Enum.filter(fn {entries, _, _} -> Enum.any?(entries) end)
    |> Enum.map(fn {entries, region, leaderboard} ->
      title = "#{Backend.Blizzard.get_region_name(region)} #{Backend.Blizzard.get_leaderboard_name(leaderboard, :long)}"
      rows = Enum.map(entries, fn %{rank: rank, account_id: account_id, rating: rating} ->
        rating_append = if rating, do: [rating], else: []
        [account_id, rank] ++ rating_append
      end)
      TableRex.quick_render!(rows, [], title)
    end)
    |> Enum.join("\n")
  end
end
