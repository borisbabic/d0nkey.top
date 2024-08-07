defmodule Backend.Feed do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Backend.Feed.DeckInteraction
  alias Backend.Feed.FeedItem
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Backend.Repo

  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

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

  def get_current_items(limit \\ 40, offset \\ 0) do
    query =
      from fi in FeedItem,
        order_by: [desc: fi.decayed_points],
        limit: ^limit,
        offset: ^offset,
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
    %{type: to_string(type), value: to_string(value), points: points}
    |> create_feed_item()
  end

  @spec create_feed_item(Map.t()) :: {:ok | FeedItem.t()} | {:error, Ecto.Changset.t()}
  def create_feed_item(attrs) do
    %FeedItem{}
    |> FeedItem.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_feed_item_points(FeedItem.t(), number()) :: {:ok, FeedItem.t()} | {:error, any()}
  def update_feed_item_points(fi = %FeedItem{}, points) do
    attrs = %{points: points}
    fi |> update_feed_item(attrs)
  end

  @spec update_feed_item(FeedItem.t(), Map.t()) :: {:ok, FeedItem.t()} | {:error, any()}
  def update_feed_item(fi = %FeedItem{}, attrs) do
    fi
    |> FeedItem.changeset(attrs)
    |> Repo.update()
  end

  @spec change_feed_item(FeedItem.t(), Map.t()) :: Ecto.Changeset
  def change_feed_item(fi = %FeedItem{}, attrs \\ %{}), do: fi |> FeedItem.changeset(attrs)

  def delete_feed_item(fi = %FeedItem{}), do: fi |> Repo.delete()

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

  @doc """
  Paginate the list of feed_items using filtrex
  filters.

  ## Examples

      iex> list_feed_items(%{})
      %{feed_items: [%FeedItem{}], ...}
  """
  @spec paginate_feed_items(map) :: {:ok, map} | {:error, any}
  def paginate_feed_items(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:feed_items), params["feed_items"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_feed_items(filter, params) do
      {:ok,
       %{
         feed_items: page.entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_feed_items(filter, params) do
    FeedItem
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:feed_items) do
    defconfig do
      number(:decay_rate, allow_decimal: true)
      number(:cumulative_decay, allow_decimal: true)
      number(:points, allow_decimal: true)
      number(:decayed_points, allow_decimal: true)
      text(:value)
      text(:string)
    end
  end

  @spec get_feed_item!(integer()) :: FeedItem.t()
  def get_feed_item!(id), do: Repo.get!(FeedItem, id)

  def handle_articles_item(latest, start_params) do
    query =
      from fi in FeedItem,
        where: fi.type == "latest_hs_articles",
        order_by: [desc: fi.inserted_at],
        limit: 1

    query
    |> Repo.one()
    |> ensure_articles_item()
    |> update_articles_item(latest, start_params)
  end

  def reduce_old_decks(new_card_ids, formats \\ [2], factor \\ 0.0001) do
    query =
      from f in FeedItem,
        join: d in Deck,
        on: fragment("?::varchar", d.id) == f.value and f.type == "deck",
        where: not fragment("? && ?", d.cards, ^new_card_ids) and d.format in ^formats,
        update: [
          set: [decay_rate: f.decay_rate * ^factor, decayed_points: f.decayed_points * ^factor]
        ]

    Repo.update_all(query, [])
  end

  defp ensure_articles_item(nil) do
    create_feed_item("latest_hs_articles", "dummy_value", 0)
    |> Util.bangify()
  end

  defp ensure_articles_item(item), do: item

  defp update_articles_item(item = %{value: v}, latest, _) when v == latest, do: {:ok, item}

  defp update_articles_item(item, latest, start_params) do
    query =
      from fi in FeedItem,
        where: fi.type != "latest_hs_articles",
        order_by: [desc: fi.decayed_points],
        select: fi.decayed_points,
        limit: 1

    highest = Repo.one(query) || 0
    points = highest + start_params[:head_start]

    attrs = %{
      points: points,
      decayed_points: points,
      decay_rate: start_params[:decay],
      cumulative_decay: 1,
      value: latest
    }

    update_feed_item(item, attrs)
  end
end
