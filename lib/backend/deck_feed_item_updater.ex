defmodule Backend.DeckFeedItemUpdater do
  @moduledoc false
  alias Backend.Feed
  alias Backend.Feed.DeckInteraction
  alias Hearthstone.DeckTracker

  @threshold 69
  @feed_item_type :deck

  def update_deck_items() do
    Feed.get_latest_deck_interactions()
    |> Enum.group_by(& &1.deck_id)
    |> Enum.each(&update_deck_item/1)
  end

  @spec update_deck_item({String.t() | integer(), [DeckInteraction.t()]}) :: any()
  def update_deck_item({deck_id, deck_interactions}) do
    points =
      deck_interactions
      |> Enum.map(&DeckInteraction.points/1)
      |> Enum.sum()
      |> apply_stats(deck_id)

    feed = Feed.feed_item(@feed_item_type, deck_id)

    cond do
      feed == nil && points >= @threshold ->
        Feed.create_feed_item(@feed_item_type, deck_id, points)

      feed != nil ->
        Feed.update_feed_item_points(feed, points)

      true ->
        nil
    end
  end

  def apply_stats(points, deck_id) do
    stats = DeckTracker.deck_stats(deck_id, [:past_week, :diamond_to_legend])
    total_games = stats.wins + stats.losses
    winrate = stats.wins / total_games

    if total_games >= 100 do
      points * :math.pow(winrate + 0.58, 2)
    else
      points
    end
  end
end
