defmodule Bot.LdbMessageHandler do
  @moduledoc false
  alias Backend.Leaderboards
  alias Backend.MastersTour.InvitedPlayer
  import Bot.MessageHandlerUtil

  def handle_battletags_leaderboard(msg) do
    {battletags, additional_criteria} = battletags_and_criteria(msg)

    get_leaderboard_entries(battletags, additional_criteria)
    |> create_tables()
    |> join_tables()
    |> send_tables(msg.channel_id)
  end

  def battletags_and_criteria(%{content: content, guild_id: guild_id}) do
    {criteria, rest} = get_criteria(content)

    battletags =
      case rest do
        [] -> get_guild_battletags!(guild_id)
        b -> b
      end

    use_max_rank = !Enum.any?(rest)

    {
      battletags,
      criteria |> Map.new() |> add_default_criteria(use_max_rank)
    }
  end

  defp add_default_criteria(criteria, use_max_rank) do
    if use_max_rank do
      %{"max_rank" => 5000}
    else
      %{}
    end
    |> Map.put("limit", 100)
    |> Map.merge(criteria)
  end

  def send_tables(tables, channel_id), do: Enum.each(tables, &send_table(&1, channel_id))

  def send_table(table, channel_id) do
    message = "```\n#{table}\n```"
    send_or_travolta(message, channel_id)
  end

  def get_leaderboard_entries(battletags_long, additional_criteria) do
    # ensure it's a list
    criteria = Enum.map(additional_criteria, & &1)

    battletags_long
    |> Enum.map(&InvitedPlayer.shorten_battletag/1)
    |> Leaderboards.get_current_player_entries(criteria)
  end

  def join_tables(tables) do
    Enum.reduce(tables, [""], fn t, [current | prev] ->
      joined = current <> "\n" <> t

      if String.length(joined) > 1950 do
        [t, current | prev]
      else
        [joined | prev]
      end
    end)
  end

  @spec create_tables(Leaderboards.categorized_entries()) :: String.t()
  def create_tables(categorized) do
    categorized
    |> Enum.filter(fn {entries, _, _} -> Enum.any?(entries) end)
    |> Enum.map(fn {entries, region, leaderboard} ->
      title =
        "#{Backend.Blizzard.get_region_name(region)} #{Backend.Blizzard.get_leaderboard_name(leaderboard, :long)}"

      rows =
        Enum.map(entries, fn %{rank: rank, account_id: account_id, rating: rating} ->
          rating_append =
            if rating, do: [Leaderboards.rating_display(rating, leaderboard)], else: []

          [account_id, rank] ++ rating_append
        end)

      TableRex.quick_render!(rows, [], title)
    end)
  end
end
