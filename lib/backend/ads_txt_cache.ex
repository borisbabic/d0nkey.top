defmodule Backend.AdsTxtCache do
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

  def nitropay_url(), do:
    Application.get_env(:backend, :nitropay_ads_txt_url, "bad_domain")
  def handle_continue(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end
  def table(), do: :ets.whereis(__MODULE__)

  def update(), do: GenServer.cast(__MODULE__, :update)

  defp update_table(table) do
    fetch_nitropay()
    |> create_ads_txt()
    |> set_ads_txt(table)
  end

  def fetch_nitropay() do
    with {:ok, %{body: body, status_code: 200}} <- HTTPoison.get(nitropay_url()) do
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
    |> set_ads_txt(table)
  end

  defp set_ads_txt(ads_txt, table), do: :ets.insert(table, {:ads_txt, ads_txt})

  defp create_ads_txt({:error, _}), do: create_ads_txt("")
  defp create_ads_txt({:ok, nitropay}), do: create_ads_txt(nitropay)
  defp create_ads_txt(nitropay) do
        """
        #{nitropay}

        # Adsense
        #{@adsense}
        """
  end

  def get() do
    table() |> Util.ets_lookup(:ads_txt, @adsense)
  end
end
