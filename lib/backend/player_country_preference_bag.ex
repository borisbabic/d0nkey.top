defmodule Backend.PlayerCountryPreferenceBag do
  use GenServer
  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.UserManager.User

  @name :player_country_preference_bag
  def start_link(default), do: GenServer.start_link(__MODULE__, default, name: @name)

  @spec init(any) :: {:ok, %{table: atom | :ets.tid()}}
  def init(_args) do
    table = :ets.new(@name, [:named_table])
    {:ok, %{table: table}, {:continue, :init}}
  end

  def handle_continue(:init, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  defp update_table(table) do
    query = from u in User,
      where: u.cross_out_country or u.show_region

    Repo.all(query)
    |> Enum.each(& update_user(&1, table))
  end

  def update_user(user), do: GenServer.cast(@name, {:update_user, user})

  def handle_cast({:update_user, user = %{cross_out_country: coc, show_region: sr}}, state = %{table: table}) do
    with %{cross_out_country: old_coc, show_region: old_sr} when old_coc != coc or old_sr != sr <- get(user) do
      update_user(user, table)
    end
    {:noreply, state}
  end
  defp update_user(%{battletag: battletag, cross_out_country: coc, show_region: sr, country_code: country}, table) when is_binary(country) do
    pref = %{
      cross_out_country: coc,
      show_region: sr
    }
    short = Backend.Battlenet.Battletag.shorten(battletag)
    :ets.insert(table, {key(battletag, country), pref})
    :ets.insert(table, {key(short, country), pref})
  end
  defp update_user(user, table), do: table

  defp key(btag, country_code) do
    "#{btag}_#{String.upcase(country_code)}"
  end

  def get(%{battletag: btag, country_code: cc}), do: get(btag, cc)
  def get(_), do: default()
  def get(nil, _country), do: default()
  def get(_btag, nil), do: default()
  def get(btag, country) when is_binary(btag) and is_binary(country), do: table() |> Util.ets_lookup(key(btag, country), default())
  def get(_btag, _country), do: default()

  defp table(), do: :ets.whereis(@name)
  def default() do
    %{
      cross_out_country: false,
      show_region: false
    }
  end

end
