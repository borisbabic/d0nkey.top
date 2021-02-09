defmodule Backend.DeckFeedItemUpdater do
  @moduledoc false
  alias Backend.Feed
  alias Backend.Feed.DeckInteraction

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
end
