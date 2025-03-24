defmodule Backend.Hearthstone.CardUpdater do
  @moduledoc "Updates cards from the official site with retries"
  @name :official_api_card_updater
  use Oban.Worker, queue: @name, unique: [period: 300]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"api_args" => api_args, "base_job" => true} = args}) do
    {:ok, %{cards: cards, page_count: page_count}} = Hearthstone.Api.get_cards(api_args)
    Backend.Hearthstone.upsert_cards(cards)

    if page_count > 1 do
      for page <- 2..page_count do
        new_api_args = Map.put(api_args, "page", page)

        args
        |> Map.put("base_job", false)
        |> Map.put("api_args", new_api_args)
        |> new()
        |> Oban.insert()
      end
    end

    :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"api_args" => %{"page" => _} = api_args} = args}) do
    {:ok, %{cards: cards}} = Hearthstone.Api.get_cards(api_args)
    Backend.Hearthstone.upsert_cards(cards)

    with %{"delay" => delay} when is_integer(delay) <- args do
      Process.sleep(delay)
    end

    :ok
  end

  def enqueue_collectible(delay \\ nil) do
    enqueue(%{"collectible" => "1"}, delay)
  end

  def enqueue_all(delay \\ nil) do
    enqueue(%{"collectible" => "0,1"}, delay)
  end

  def enqueue_latest_set() do
    %{slug: slug} = Backend.Hearthstone.latest_set()

    %{"collectible" => "0,1", "set" => slug}
    |> enqueue()
  end

  @base_args %{"pageSize" => 40, "locale" => "en_US"}
  def enqueue(additional_args, delay \\ nil) do
    Map.merge(@base_args, additional_args)
    |> do_enqueue(delay)
  end

  defp do_enqueue(api_args, delay) do
    %{"base_job" => true, "api_args" => api_args, "delay" => delay}
    |> new()
    |> Oban.insert()
  end
end
