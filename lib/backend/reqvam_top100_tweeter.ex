defmodule Backend.ReqvamTop100Tweeter do
  @moduledoc false
  alias Backend.Leaderboards
  alias Backend.Blizzard.Leaderboard.Entry
  @type msg :: message :: String.t() | {message :: String.t(), media :: String.t()}
  @type message_info :: %{
          entry: Entry.t() | nil,
          gaby_eu: Entry.t() | nil,
          day_of_week: integer(),
          date: Date.t()
        }
  def check_and_tweet() do
    Task.start(&do_check_and_tweet/0)
  end

  defp do_check_and_tweet() do
    with {:ok, config} <- Application.fetch_env(:backend, :req_t100_twitter_info),
         :ok <- ExTwitter.configure(:process, config),
         {:ok, season} <-
           Leaderboards.get_season(%Hearthstone.Leaderboards.Season{
             region: "US",
             leaderboard_id: "STD",
             season_id: nil
           }),
         %{entries: entries} <- Leaderboards.get_shim([:latest_in_season, {"season", season}]) do
      entry = Enum.find(entries, &(&1.account_id == "reqvam"))
      date = Date.utc_today()

      info = %{
        entry: entry,
        gaby_eu: entry("Gaby", "EU"),
        day_of_week: Date.day_of_week(date),
        date: date
      }

      message = info |> msg() |> pick_msg()
      picture = info |> pic()
      tweet(message, picture)
    end
  end

  def entry(account_id, region, ldb \\ "STD") do
    case Leaderboards.get_leaderboard(region, ldb, nil) do
      %{entries: entries} -> Enum.find(entries, &(&1.account_id == account_id))
      _ -> nil
    end
  end

  @spec pick_msg([String.t()] | String.t()) :: String.t()
  def pick_msg(msgs) when is_list(msgs), do: msgs |> Enum.random() |> pick_msg()
  def pick_msg(msg), do: msg

  @spec pic(message_info()) :: String.t()
  def pic(%{entry: %{rank: rank}}) when rank < 101, do: "still_top_100.jpg"
  def pic(_), do: nil

  def tweet({message, picture}, _), do: tweet(message, picture)

  def tweet(message, nil) do
    ExTwitter.update(message)
  end

  def tweet(message, file_name) do
    case File.read("assets/static/images/reqvam/#{file_name}") do
      {:ok, file} -> ExTwitter.update_with_media(message, file)
      _ -> tweet(message, nil)
    end
  end

  defp get_mt_score(mt) do
    with {:ok, battlefy_id} <- Backend.MastersTour.TourStop.get_battlefy_id(mt),
         %{stages: [stage | _]} <- Backend.Battlefy.get_tournament(battlefy_id),
         stage_standings <- Backend.Battlefy.get_stage_standings(stage),
         %{wins: wins, losses: losses} <-
           Enum.find(stage_standings, &(&1.team && &1.team.name =~ "reqvam#")) do
      {:ok, {wins, losses}}
    else
      nil -> {:error, :not_playing}
      _ -> {:error, :couldnot_get_results}
    end
  end

  defp mt_message_rank_part(rank) when rank <= 100 do
    ["reqvam is currently #{rank} on NA"]
  end

  defp mt_message_rank_part(_) do
    ["reqvam isn't top 100 NA"]
  end

  defp mt_message_score_part({:ok, {wins, losses = 0}}),
    do: ["He is #{wins} - #{losses} ! Go Paul! Go! Carry reqvam!"]

  defp mt_message_score_part({:ok, {wins, losses}}) when wins > 6,
    do: ["He is #{wins} - #{losses}. Top 16 wooohoooo"]

  defp mt_message_score_part({:ok, {wins = 0, losses}}),
    do: ["He is #{wins} - #{losses} Sadge. Where is Paul when you need somebody to carry you"]

  defp mt_message_score_part({:ok, {wins, losses = 1}}) when wins < 7,
    do: ["He is #{wins} - #{losses}. Top 16 incoming Copium"]

  defp mt_message_score_part({:ok, {wins, losses}}),
    do: ["He is #{wins} - #{losses}. That's better than 0 - #{wins + losses} !!!"]

  defp mt_message_score_part({:error, :not_playing}), do: ["He is... not playing??"]
  defp mt_message_score_part(_), do: [" Well, just check d0nkey.top, duhhh"]

  defp mt_message(score, rank) do
    rank_parts = mt_message_rank_part(rank)
    score_parts = mt_message_score_part(score)

    for rank_part <- rank_parts,
        score_part <- score_parts,
        do: "#{rank_part} but what about the MT? #{score_part}"
  end

  def handle_mt(mt, entry) do
    get_mt_score(mt) |> mt_message(get_rank(entry))
  end

  def get_rank(%{entry: %{rank: rank}}), do: rank
  def get_rank(_), do: nil
  @spec msg(message_info()) :: msg() | [msg()]
  def msg(%{entry: %{rank: 69}}), do: "Nice!"

  def msg(%{date: %{year: 2022, month: 2, day: day}, entry: entry}) when day in [18, 19],
    do: handle_mt(:"Masters Tour One", entry)

  def msg(%{entry: %{rank: 42}}),
    do:
      "\"What rank is reqvam on NA\" is probably not the ultimate question, but the answer is the same: 42"

  def msg(%{entry: %{rank: 1}}),
    do: [
      "Reqvam is #1 ! On NA! Maybe it's time to play on a tougher server?",
      "Reqvam is rank 1! That's 1 factorial and just RANK 1 ! What an amazing achievement by such an amazing skeleton"
    ]

  def msg(%{entry: %{rank: 21}}), do: "Reqvam is 21 - I remember when he was top 20 NA"

  def msg(%{entry: %{rank: 24}}),
    do: ["Reqvam is top 100, he is 4! ie 24, surprise factorial! 🤓", top_100_messages(24)]

  def msg(%{entry: %{rank: 101}}), do: {"Reqvam is not top 100, he is 101.", "ha-ha.jpg"}

  def msg(%{entry: %{rank: rank}, date: %{day: 1, month: 1}}) when rank < 101,
    do: "Reqvam is #{rank} ! Seems like somebody didn't have new years plans"

  def msg(%{entry: %{rank: rank}, date: %{day: 1}}) when rank < 101,
    do: "Reqvam is #{rank} ! Seems like somebody had some free time to get to legend already"

  def msg(%{entry: %{rank: rank}, date: %{day: 2}}) when rank < 101,
    do: "Reqvam is #{rank} ! But it's basically day 1 so is it even that high?"

  def msg(%{entry: %{rank: 5}}),
    do: "Reqvam is #5 ! If only he'd let Paul play maybe he'd be rank 1 by now"

  def msg(%{entry: %{rank: rank}, date: %{year: 2021, month: 11, day: day}})
      when rank < 16 and day > 28,
      do:
        "Reqvam is #{rank} ! Top 16 and the month is almost over! Which actually isn't too suprising because ladder doesn't matter KEKW"

  def msg(%{entry: %{rank: rank}, date: %{day: 31}}) when rank < 101,
    do: "Reqvam is #{rank} ! Is he actually going to finish top 100 😮???"

  def msg(%{entry: %{rank: 45}}),
    do: "Reqvam is 45 ! If he keeps at it maybe some day he will be top 16 on Americas ladder"

  def msg(%{entry: %{rank: rank}, date: %{day: day}}) when rank < 101 and day < 5,
    do: [
      "Reqvam is #{rank} ! But is it really that impressive this early?",
      "Reqvam is #{rank} ! But it's early, will it hold?"
    ]

  def msg(%{entry: %{rank: rank}}) when rank < 10,
    do: [
      "Ehhh... This one won't be in the mt stats. He's only #{rank} ",
      "Reqvam is #{rank} ! Wow, a single digit rank! Reqvam is really making it easy to fit this text into a tweet",
      top_100_messages(rank)
    ]

  def msg(%{entry: %{rank: rank}, day_of_week: 5}) when rank < 101,
    do:
      "I don't care if Mondays blue. Tuesday's grey and Wednesday too. Thursday I don't care about you. On Friday Reqvams #{rank}"

  def msg(info = %{entry: %{rank: rank}}) when rank < 101,
    do: top_100_messages(rank) |> add_gaby(info)

  def msg(%{date: %{day: 15}}),
    do:
      "Oh, no, reqvam isn't top 100. He should put Noz in his decks because he needs to do some serious climbing"

  def msg(%{date: %{day: day}}) when day < 5,
    do: [
      "Reqvam is not top 100, but it's still early",
      "The season recently started, maybe paul is keeping him busy? He isn't top 100 yet"
    ]

  def msg(%{date: %{day: day}}) when day < 15,
    do: [
      "Not top 100. Nope.",
      "It's early, but it's not that early. Still not top 100??",
      "Reqvam isn't top 100, so that means he is the perfect person to get some coaching from https://metafy.gg/@reqvam"
    ]

  def msg(%{date: %{day: day}}) when day > 15,
    do: [
      "What the heck? Not top 100! It's already today's date!!!",
      "Come on Paul, whatya doing! Reqvam aint top 100. You gotta help reqvam get a high rank so he can get those twitch views!",
      "Reqvam is not top 100, so that means he is the perfect person to get some coaching from https://metafy.gg/@reqvam"
    ]

  def msg(%{date: %{day: day}}) when day > 25,
    do: [
      "The season is almost over and reqvam isn't top 100? What a washed up player. Better find somebody else to watch on twitch",
      "Not top 100 this late in the month? Is reqvam even playing Standard anymore? Somebody go tell d0nkey to turn off this bot"
    ]

  def top_100_messages(rank),
    do: [
      "Where did you come from? Where did Reqvam go? Something something cotton eyed Joe. Reqvam is #{rank}",
      "Reqvam is #{rank} ! That is top 100. What an amazing accomplishment by someone exactly worthy of such an accomplishment.",
      "Reqvam is top 100 ! He is currently #{rank} ! I guess he isn't completely washed up",
      "Reqvam is #{rank} ! Or maybe it's actually Paul that is #{rank}",
      """
      Reqvam is #{rank} ! And since I guess at least one of these messages should mention his twitch go give him a follow (as if somebody following this bot isn't already following him):

      https://www.twitch.tv/reqvam
      """,
      "Another day of reqvam pretending it's not actually Paul that is top 100 (currently #{rank})",
      "Reqvam is #{rank} ! Yes, the space before the ! is there so people can't make factorial jokes.",
      "Reqvam is #{rank} ! *insert amusing comment* - coming up with these aint easy, if you have a suggestion fill this out: https://forms.gle/X6Wovae9aHGpvACZ7"
    ]

  defp add_gaby(msgs, %{gaby_eu: %{rank: gaby_rank}, entry: %{rank: rank}})
       when gaby_rank < rank and rank < 101,
       do: [
         "Reqvam is #{rank} on NA! That’s almost as good as Gaby on EU (he is #{gaby_rank})!"
         | msgs
       ]

  defp add_gaby(msgs, _), do: msgs
end
