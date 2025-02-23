defmodule TwitchBot.MessageCreator do
  import TwitchBot.Util, only: [parse_chat: 1]
  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.UserManager.User
  alias Backend.Streaming.Streamer

  def create_messages(matching, message_info = %{chat: chat}) when is_list(matching) do
    user_values = user_values(chat)
    values = base_values(message_info) |> Map.merge(user_values)
    Enum.map(matching, &create_message(&1, message_info, values))
  end

  defp base_values(message_info) do
    %{
      "message" => message_info.message,
      "sender" => message_info.sender
    }
  end

  def create_message(config, %{chat: _chat}, base_values) do
    extra_values = Map.get(config, :extra_values, %{})
    values = Map.merge(base_values, extra_values) |> add_leaderboard_status()

    with {:ok, template} <- Solid.parse(config.response),
         message when is_binary(message) <- Solid.render(template, values) do
      message
    end
  end

  @spec user_values(any) :: %{optional(<<_::64, _::_*8>>) => any}
  def user_values(chat) do
    case chat |> parse_chat() |> get_user() do
      nil ->
        %{}

      user ->
        %{
          "streamer_decks_url" =>
            "https://www.hsguru.com/streamer-decks?twitch_id=#{user.twitch_id}"
        }
        |> add_latest_replay(user)
    end
  end

  def get_user(chat) do
    query =
      from u in User,
        inner_join: s in Streamer,
        on: s.twitch_id == fragment("?::INTEGER", u.twitch_id),
        where: ilike(^chat, s.twitch_login) or ilike(^chat, s.hsreplay_twitch_login)

    Repo.one(query)
  end

  def add_leaderboard_status(values = %{"ldb_player" => player}) do
    status =
      Backend.Leaderboards.get_current_player_entries([player])
      |> Enum.filter(&(&1 |> elem(0) |> Enum.any?()))
      |> Enum.map_join(" | ", fn {[%{rank: rank, rating: rating} | _],
                                  %{region: region, leaderboard_id: leaderboard}} ->
        [
          Backend.Blizzard.get_region_name(region, :short),
          Backend.Blizzard.get_leaderboard_name(leaderboard, :short),
          rank,
          rating
        ]
        |> Enum.filter(& &1)
        |> Enum.join(" ")
      end)

    Map.put(values, "leaderboard_status", status)
  end

  def add_leaderboard_status(values), do: values

  defp add_latest_replay(previous_values, %{battletag: battletag}) do
    criteria = [
      {"player_btag", battletag},
      {"order_by", "latest"},
      {"limit", 10},
      {"public", true}
    ]

    Hearthstone.DeckTracker.games(criteria)
    |> Enum.find_value(&Hearthstone.DeckTracker.replay_link/1)
    |> case do
      nil -> previous_values
      url -> Map.put(previous_values, "latest_replay_url", url)
    end
  end
end
