defmodule Hearthstone.Api do
  @moduledoc false
  use GenServer
  require Logger
  @name :hearthstone_blizzard_access_token

  @six_hours 21_600_000
  @five_min 300_000

  alias Hearthstone.Response.{
    Metadata,
    Cards
  }

  @default_locale "en_US"
  @base_url "https://eu.api.blizzard.com/hearthstone"

  @spec get_metadata(String.t()) :: {:ok, Metadata.t()} | {:error, any()}
  def get_metadata(locale \\ @default_locale) do
    url = "#{@base_url}/metadata?locale=#{locale}"

    with {:ok, body} <- get_body(url) do
      Metadata.from_raw_map(body)
    end
  end

  @spec get_cards(String.t()) :: {:ok, Cards.t()} | {:error, any()}
  def get_mercenaries(opts \\ %{}) do
    %{"gameMode" => "mercenaries"}
    |> Map.merge(opts)
    |> get_cards()
  end

  @spec get_cards(String.t()) :: {:ok, Cards.t()} | {:error, any()}
  def get_cards(opts \\ %{}) do
    query = URI.encode_query(opts)
    url = "#{@base_url}/cards?#{query}"

    case get_body(url) do
      {:ok, body} ->
        Cards.from_raw_map(body)

      e = {:error, _} ->
        e

      _ ->
        {:error, :unknown_error}
    end
  end

  @spec next_page(String.t()) :: {:ok, Cards.t()} | {:error, any()}
  def next_page(%{page: page}, opts \\ %{}), do: opts |> Map.put("page", page + 1) |> get_cards()

  @spec get_body(String.t(), list(), list()) :: {:ok, Map.t()} | {:error, any()}
  def get_body(url, base_headers \\ [], opts \\ []) do
    with {:ok, token} <- access_token(),
         headers <- [{"Authorization", "Bearer #{token}"} | base_headers],
         {:ok, %{body: body}} <- HTTPoison.get(url, headers, opts) do
      Poison.decode(body)
    end
  end

  @spec create_access_token() :: {:ok, String.t()} | {:error, any()}
  def create_access_token() do
    create_access_token(
      Application.get_env(:backend, :bnet_client_id),
      Application.get_env(:backend, :bnet_client_secret)
    )
  end

  @spec create_access_token(String.t(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def create_access_token(client_id, client_secret) do
    credentials = "#{client_id}:#{client_secret}" |> Base.encode64()

    with {:ok, %{body: body}} <-
           HTTPoison.post(
             "https://eu.battle.net/oauth/token",
             {:form, [{"grant_type", "client_credentials"}]},
             [{"Authorization", "Basic #{credentials}"}]
           ),
         {:ok, %{"access_token" => access_token}} <- Poison.decode(body) do
      {:ok, access_token}
    else
      e = {:error, _} ->
        e

      {:ok, r = %{"error" => "unauthorized"}} ->
        with {:ok, encoded} <- Poison.encode(r) do
          Logger.warn("Unauthorized blizzard response: #{encoded}")
        end

        {:error, :unauthorized}

      _ ->
        {:error, :unknown_error}
    end
  end

  @spec access_token() :: {:ok, String.t()} | {:error, any()}
  def access_token() do
    case :ets.lookup(table(), :access_token) do
      [{:access_token, token}] ->
        {:ok, token}

      _ ->
        with {:ok, token} <- create_access_token() do
          set_access_token(token)
          {:ok, token}
        end
    end
  end

  #### GENSERVER

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    table = :ets.new(@name, [:named_table])

    send_loop(0)
    {:ok, %{table: table}}
  end

  def handle_info(:loop, state) do
    case create_access_token() do
      {:ok, token} ->
        set_access_token(token)
        send_loop(@six_hours)

      {:error, _} ->
        send_loop(@five_min)
    end

    {:noreply, state}
  end

  def handle_cast({:set_access_token, token}, state = %{table: table}) do
    :ets.insert(table, {:access_token, token})
    {:noreply, state}
  end

  defp table(), do: :ets.whereis(@name)

  defp send_loop(after_ms), do: Process.send_after(self(), :loop, after_ms)

  defp set_access_token(access_token) do
    GenServer.cast(@name, {:set_access_token, access_token})
  end
end
