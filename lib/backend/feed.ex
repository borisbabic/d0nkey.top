defmodule Backend.Feed do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Backend.Feed.DeckInteraction
  alias Backend.Feed.FeedItem
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Backend.Repo

  def inc_deck_copied(deck), do: inc(deck, :copied)
  def inc_deck_expanded(deck), do: inc(deck, :expanded)

  def inc(deck, field) when is_binary(deck) do
    deck
    |> Hearthstone.create_or_get_deck()
    |> Util.ok!()
    |> inc(field)
  end

  def inc(deck = %Deck{}, field) do
    di =
      deck
      |> get_or_create_deck_interaction()
      |> Util.ok!()

    query =
      from di in DeckInteraction,
        where: di.id == ^di.id

    query |> Repo.update_all(inc: [{field, 1}])
  end

  @spec get_or_create_deck_interaction(Deck.t()) :: {:ok, DeckInteraction.t()}
  def get_or_create_deck_interaction(deck = %Deck{}) do
    deck
    |> deck_interaction()
    |> case do
      nil -> create_deck_interaction(deck)
      di -> {:ok, di}
    end
  end

  def create_deck_interaction(deck), do: create_deck_interaction(deck, get_current_start())

  def create_deck_interaction(deck, start) do
    %DeckInteraction{}
    |> DeckInteraction.changeset(%{copied: 0, expanded: 0, period_start: start, deck: deck})
    |> Repo.insert()
  end

  def deck_interaction(deck), do: deck_interaction(deck, get_current_start())

  def deck_interaction(%Deck{id: deck_id}, start) do
    query =
      from di in DeckInteraction,
        join: d in assoc(di, :deck),
        where: d.id == ^deck_id and di.period_start == ^start,
        select: di

    Repo.one(query)
  end

  def get_current_start() do
    now = NaiveDateTime.utc_now()

    NaiveDateTime.new(now.year, now.month, now.day, now.hour, 0, 0)
    |> Util.bangify()
  end

  def get_current_items(limit \\ 40) do
    query =
      from fi in FeedItem,
        order_by: [desc: fi.decayed_points],
        limit: ^limit,
        select: fi

    Repo.all(query)
  end

  def get_latest_deck_interactions(num \\ 24) do
    now = NaiveDateTime.utc_now()

    start =
      NaiveDateTime.new(now.year, now.month, now.day, now.hour, 0, 0)
      |> Util.bangify()
      |> NaiveDateTime.add(-3600 * num)

    query =
      from di in DeckInteraction,
        where: di.period_start >= ^start and di.period_start < ^now,
        select: di

    Repo.all(query)
  end

  @spec feed_item(String.t() | atom(), String.t() | atom() | integer()) :: FeedItem.t() | nil
  def feed_item(type, value) when is_binary(type) and is_binary(value) do
    query =
      from f in FeedItem,
        where: f.type == ^type and f.value == ^value,
        select: f

    Repo.one(query)
  end

  def feed_item(type, value), do: feed_item(to_string(type), to_string(value))

  @spec create_feed_item(atom() | String.t(), integer() | String.t() | atom(), number()) ::
          {:ok, FeedItem.t()} | {:error, any()}
  def create_feed_item(type, value, points \\ 0.0) do
    attrs = %{type: to_string(type), value: to_string(value), points: points}

    %FeedItem{}
    |> FeedItem.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_feed_item_points(FeedItem.t(), number()) :: {:ok, FeedItem.t()} | {:error, any()}
  def update_feed_item_points(fi = %FeedItem{}, points) do
    fi
    |> FeedItem.changeset(%{points: points})
    |> Repo.update()
  end

  def decay_feed_items() do
    query = from(fi in FeedItem)

    query
    |> Repo.update_all(
      set: [
        cumulative_decay: dynamic([di], di.cumulative_decay * di.decay_rate),
        decayed_points: dynamic([di], di.points * di.cumulative_decay)
      ]
    )
  end
end
