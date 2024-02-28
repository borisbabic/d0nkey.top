defmodule Backend.AdsTxtCache do
  @moduledoc "Combines ads.txt for google and nitropay"
  use GenServer

  @adsense "google.com, pub-8835820092180114, DIRECT, f08c47fec0942fa0"
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(__MODULE__, [:named_table])
    init_table(table)
    {:ok, %{table: table}, {:continue, :update}}
  end

  def handle_continue(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  def table(), do: :ets.whereis(__MODULE__)

  def update(), do: GenServer.cast(__MODULE__, :update)

  defp update_table(table) do
    for {_host, %{enable_adsense: true, nitropay_url: url}} <- config() do
      fetch_nitropay(url)
      |> create_ads_txt()
      |> set_ads_txt(table, url)
    end
  end

  def fetch_nitropay(url) do
    with {:ok, %{body: body, status_code: 200}} <- HTTPoison.get(url) do
      {:ok, body}
    end
  end

  def handle_cast(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  defp init_table(table) do
    File.read("assets/static/ads.txt")
    |> create_ads_txt()
    |> set_ads_txt(table, default_url())
  end

  defp set_ads_txt(ads_txt, table, url), do: :ets.insert(table, {url, ads_txt})

  defp default_url() do
    Application.fetch_env(:backend, :default_nitropay_ads_txt_url)
  end

  defp create_ads_txt({:error, _}), do: create_ads_txt("")
  defp create_ads_txt({:ok, nitropay}), do: create_ads_txt(nitropay)

  defp create_ads_txt(nitropay) do
    """
    #{nitropay}

    # Adsense
    #{@adsense}
    """
  end

  def get(url) do
    table() |> Util.ets_lookup(url, @adsense)
  end

  def config() do
    Application.fetch_env!(:backend, :ads_config)
  end
end
