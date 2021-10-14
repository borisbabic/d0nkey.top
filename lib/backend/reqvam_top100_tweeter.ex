defmodule Backend.ReqvamTop100Tweeter do
  alias Backend.Leaderboards
  def check_and_tweet() do
    Task.start(&do_check_and_tweet/0)
  end
  defp do_check_and_tweet() do
    with {:ok, config} <- Application.fetch_env(:backend, :req_t100_twitter_info),
    :ok <- ExTwitter.configure(:process, config),
    %{entries: entries} <- Leaderboards.get_leaderboard("US", "STD", nil) do
      message = case Enum.find(entries, & &1.rank <= 100 && &1.account_id == "reqvam") do
        %{rank: 1} -> "DING! DING! DING! DING! Reqvam is #1! On NA! Maybe it's time to play on a tougher server?"
        %{rank: rank} when rank < 10 -> "Reqvam is #{rank}! Wowza! One might think he is good at the game"
        %{rank: rank} -> [
          "Reqvam is top 100! He is currently #{rank}! I guess he isn't completely washed up",
          "Reqvam is #{rank}! Or maybe it's actually Paul that is #{rank}",
        ] |> Enum.random()
        _ -> not_top_100_tweet()
      end
      ExTwitter.update(message)
    end
  end

  defp not_top_100_tweet() do
    date = Date.utc_today()
    cond do
      date.day < 5  ->
      [
        "Reqvam is not top 100, but it's still early",
        "The season recently started, maybe paul is keeping him busy? He isn't top 100 yet",
      ]
      date.day <= 15 ->
        [
          "Not top 100. Nope.",
          "It's early, but it's not that early. Still not top 100??",
        ]
      date.day > 15 ->
        [
          "What the heck? Not top 100! It's already today's date!!!",
          "Come on Paul, whatya doing! Reqvam aint top 100. You gotta help reqvam get a high rank so he can get those twitch views!",
        ]
      date.day > 25 ->
        [
          "The season is almost over and reqvam isn't top 100? What a washed up player. Better find somebody else to watch on twitch",
          "Not top 100 this late in the month? Is reqvam even playing Standard anymore? Somebody go tell d0nkey to turn off this bot",
        ]
    end
    |> Enum.random()
  end
end
