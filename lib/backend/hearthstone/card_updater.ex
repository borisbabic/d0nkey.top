defmodule Backend.Hearthstone.CardUpdater do
  @moduledoc "Updates cards from the official site with retries"
  @name :official_api_card_updater
  use Oban.Worker, queue: @name, unique: [period: 300]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"api_args" => api_args, "base_job" => true}}) do
    {:ok, %{cards: cards, page_count: page_count}} = Hearthstone.Api.get_cards(api_args)
    Backend.Hearthstone.upsert_cards(cards)

    if page_count > 1 do
      for page <- 2..page_count do
        new_args = Map.put(api_args, "page", page)

        %{"api_args" => new_args}
        |> new()
        |> Oban.insert()
      end
    end

    :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"api_args" => %{"page" => _} = api_args}}) do
    {:ok, %{cards: cards}} = Hearthstone.Api.get_cards(api_args)
    Backend.Hearthstone.upsert_cards(cards)
  end

  def enqueue_collectible() do
    %{"collectible" => "1"}
    |> enqueue()
  end

  def enqueue_all() do
    %{"collectible" => "0,1"}
    |> enqueue()
  end

  def enqueue_latest_set() do
    %{slug: slug} = Backend.Hearthstone.latest_set()

    %{"collectible" => "0,1", "set" => slug}
    |> enqueue()
  end

  @base_args %{"pageSize" => 40, "locale" => "en_US"}
  def enqueue(additional_args) do
    Map.merge(@base_args, additional_args)
    |> do_enqueue()
  end

  defp do_enqueue(api_args) do
    %{"base_job" => true, "api_args" => api_args}
    |> new()
    |> Oban.insert()
  end
end
