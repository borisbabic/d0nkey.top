defmodule Backend.ReqvamTop100Tweeter do
  alias Backend.Leaderboards
  def check_and_tweet() do
    Task.start(&do_check_and_tweet/0)
  end
  defp do_check_and_tweet() do
    with {:ok, config} <- Application.fetch_env(:backend, :req_t100_twitter_info),
    :ok <- ExTwitter.configure(:process, config),
    %{entries: entries} <- Leaderboards.get_leaderboard("US", "STD", nil) do
      message =
        entries
        |> Enum.find(entries, & &1.account_id == "reqvam")
        |> msg(Date.utc_today())
        |> pick_msg()
      ExTwitter.update(message)
    end
  end

  @spec pick_msg([String.t] | String.t()) :: String.t()
  def pick_msg(msgs) when is_list(msgs), do: msgs |> Enum.random() |> pick_msg()
  def pick_msg(msg), do: msg

  @spec msg(Backend.Blizzard.Leaderboard.Entry.t(), Date.t()) :: String.t() | [String.t()]
  def msg(%{rank: 69}, _date), do: "Nice!"
  def msg(%{rank: 42}, _date), do: "\"What rank is reqvam on NA\" is probably not the ultimate question, but the answer is the same: 42"
  def msg(%{rank: 1}, _date), do: "Reqvam is #1 ! On NA! Maybe it's time to play on a tougher server?"
  def msg(%{rank: 24}, _date), do: ["Reqvam is top 100, he is 4! ie 24, surprise factorial! 🤓", top_100_messages(24)]
  def msg(%{rank: 101}, _), do: "Reqvam is not top 100, he is 101. Ha! Ha!"
  def msg(%{rank: rank}, %{day: 1, month: 1}) when rank < 101, do: "Reqvam is #{rank} ! Seems like somebody didn't have new years plans"
  def msg(%{rank: rank}, %{day: 1}) when rank < 101, do: "Reqvam is #{rank} ! Seems like somebody had some free time to get to legend already"
  def msg(%{rank: rank}, %{day: 2}) when rank < 101, do: "Reqvam is #{rank} ! But it's basically day 1 so is it even that high?"
  def msg(%{rank: rank}, %{day: day}) when rank < 101 and day < 5, do: [
    "Reqvam is #{rank} ! But is it really that impressive this early?",
    "Reqvam is #{rank} ! But it's early, will it hold?"
  ]
  def msg(%{rank: rank}, _date) when rank < 101, do: top_100_messages(rank)
  def msg(_entry, %{day: day}) when day < 5, do:
      [
        "Reqvam is not top 100, but it's still early",
        "The season recently started, maybe paul is keeping him busy? He isn't top 100 yet",
      ]
  def msg(_entry, %{day: day}) when day < 15, do:
        [
          "Not top 100. Nope.",
          "It's early, but it's not that early. Still not top 100??",
          "Reqvam isn't top 100, so that means he is the perfect person to get some coaching from https://metafy.gg/@reqvam",
        ]
  def msg(_entry, %{day: day}) when day > 15, do:
        [
          "What the heck? Not top 100! It's already today's date!!!",
          "Come on Paul, whatya doing! Reqvam aint top 100. You gotta help reqvam get a high rank so he can get those twitch views!",
          "Reqvam isn't top 100, so that means he is the perfect person to get some coaching from https://metafy.gg/@reqvam",
        ]
  def msg(_entry, %{day: day}) when day > 25, do:
        [
          "The season is almost over and reqvam isn't top 100? What a washed up player. Better find somebody else to watch on twitch",
          "Not top 100 this late in the month? Is reqvam even playing Standard anymore? Somebody go tell d0nkey to turn off this bot",
        ]

  def top_100_messages(rank), do:
      [
        "Reqvam is #{rank} ! That is top 100. What an amazing accomplishment by someone exactly worthy of such an accomplishment.",
        "Reqvam is top 100 ! He is currently #{rank} ! I guess he isn't completely washed up",
        "Reqvam is #{rank} ! Or maybe it's actually Paul that is #{rank}",
        """
        Reqvam is #{rank} ! And since I guess at least one of these messages should mention his twitch go give him a follow (as if somebody following this bot isn't already following him):

        https://www.twitch.tv/reqvam
        """,
        "Reqvam is #{rank} ! Yes, the space before the ! is there so people can't make factorial jokes.",
        "Reqvam is #{rank} ! *insert amusing comment* - coming up with these aint easy, if you have a suggestion fill this out: https://forms.gle/X6Wovae9aHGpvACZ7"
      ]
end
