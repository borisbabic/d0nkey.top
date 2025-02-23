defmodule Bot.LdbMessageHandler do
  @moduledoc false
  alias Backend.Leaderboards
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.Blizzard
  import Bot.MessageHandlerUtil

  def handle_battletags_leaderboard(msg) do
    {battletags, additional_criteria} = battletags_and_criteria(msg)

    get_leaderboard_entries(battletags, additional_criteria)
    |> create_tables()
    |> join_tables()
    |> send_tables(msg.channel_id)
  end

  def handle_top_leaderbaord(msg) do
    {raw_criteria, rest} = get_criteria(msg.content)
    leaderboard_options = parse_leaderboard_options(rest)

    base_criteria =
      raw_criteria
      |> ensure_region(leaderboard_options)
      |> ensure_leaderboard_id(leaderboard_options)
      |> ensure_season_id(leaderboard_options)

    criteria = [:latest_in_season, {"order_by", "rank"} | base_criteria] |> add_limit(10)

    Leaderboards.entries(criteria)
    |> create_season_table(Leaderboards.extract_season_info(criteria))
    |> send_table(msg.channel_id)
  end

  defp ensure_region(criteria, %{region: region}) do
    case Leaderboards.extract_region(criteria) do
      nil -> [{"region", region} | criteria]
      _ -> criteria
    end
  end

  defp ensure_leaderboard_id(criteria, %{leaderboard_id: leaderboard_id}) do
    case Leaderboards.extract_leaderboard_id(criteria) do
      nil -> [{"leaderboard_id", leaderboard_id} | criteria]
      _ -> criteria
    end
  end

  defp ensure_season_id(criteria, %{season_id: parsed_season_id}) do
    case {Leaderboards.extract_season_id(criteria), parsed_season_id} do
      {nil, nil} ->
        region = Leaderboards.extract_region(criteria)
        leaderboard = Leaderboards.extract_leaderboard_id(criteria)
        season_id = Blizzard.get_current_ladder_season(leaderboard, region)
        [{"season_id", season_id} | criteria]

      {nil, season_id} ->
        [{"season_id", season_id} | criteria]

      _ ->
        criteria
    end
  end

  def battletags_and_criteria(%{content: content, guild_id: guild_id}) do
    {criteria, rest} = get_criteria(content)

    battletags =
      case rest do
        [] -> get_guild_battletags!(guild_id)
        b -> b
      end

    use_max_rank = !Enum.any?(rest)

    default_criteria = default_criteria(use_max_rank)

    {
      battletags,
      criteria |> add_default_criteria(default_criteria)
    }
  end

  defp add_limit(criteria, limit) do
    if List.keymember?(criteria, "limit", 0) do
      criteria
    else
      [{"limit", limit} | criteria]
    end
  end

  defp default_criteria(use_max_rank) do
    max_rank_criteria(use_max_rank)
    |> add_limit(100)
  end

  defp max_rank_criteria(true), do: [{"max_rank", 5000}]
  defp max_rank_criteria(_), do: []

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
    |> Enum.map(&create_season_table/1)
  end

  defp create_season_table({entries, r, l}) do
    create_season_table(entries, %{leaderboard_id: l, region: r})
  end

  defp create_season_table({entries, ldb_info}), do: create_season_table(entries, ldb_info)

  defp create_season_table(entries, ldb_info) do
    title = create_title(ldb_info)

    rows =
      create_rows(entries, ldb_info)

    TableRex.quick_render!(rows, [], title)
  end

  defp create_rows(entries, %{leaderboard_id: leaderboard}) do
    Enum.map(entries, fn %{rank: rank, account_id: account_id, rating: rating} ->
      rating_append =
        if rating, do: [Leaderboards.rating_display(rating, leaderboard)], else: []

      [account_id, rank] ++ rating_append
    end)
  end

  defp create_title(%{region: region, leaderboard_id: leaderboard} = ldb_info) do
    base =
      "#{Backend.Blizzard.get_region_name(region)} #{Backend.Blizzard.get_leaderboard_name(leaderboard, :long)}"

    case ldb_info do
      %{season_id: season_id} when is_number(season_id) or is_binary(season_id) ->
        base <> " (#{season_id})"

      _ ->
        base
    end
  end

  @doc """
  Extracts the season_id, leaderboard_id and region from the options passed to !leaderboard

  ## Example
  iex> Bot.LdbMessageHandler.parse_leaderboard_options([" 100", "AP", "BG"])
  %{season_id: 100, leaderboard_id: :BG, region: AP}
  iex> Bot.LdbMessageHandler.parse_leaderboard_options(" 69 adfsf ql5q THIS IS AWESOME BG"])
  %{season_id: 69, leaderboard_id: :BG, region: EU}
  """
  @spec parse_leaderboard_options([String.t()] | String.t()) :: %{
          leaderboard_id: Blizzard.leaderboard(),
          region: Blizzard.leaderboard(),
          season_id: integer()
        }
  def parse_leaderboard_options(options) do
    normalized =
      if is_binary(options) do
        String.splitter(options, " ")
      else
        options
      end

    parsed =
      normalized
      |> Stream.map(&String.upcase/1)
      |> Enum.reduce(
        %{},
        fn opt, acc ->
          case {Blizzard.to_region(opt), Blizzard.to_leaderboard(opt), Integer.parse(opt)} do
            {{:ok, region}, _, _} -> Map.put_new(acc, :region, region)
            {_, {:ok, leaderboard_id}, _} -> Map.put_new(acc, :leaderboard_id, leaderboard_id)
            {_, _, {season_id, _}} -> Map.put_new(acc, :season_id, season_id)
            _ -> acc
          end
        end
      )

    default = %{
      season_id: nil,
      leaderboard_id: :STD,
      region: :EU
    }

    Map.merge(default, parsed)
  end
end
