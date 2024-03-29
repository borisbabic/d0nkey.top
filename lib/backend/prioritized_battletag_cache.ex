defmodule Backend.PrioritizedBattletagCache do
  @moduledoc "Holds the battletag info by "
  use GenServer
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.Battlenet.Battletag
  @name :prioritized_battletag_cache
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_) do
    table = :ets.new(@name, [:named_table])
    Process.send_after(self(), :update_cache, 0)
    {:ok, %{table: table}}
  end

  defp update_table(table) do
    all = Backend.Battlenet.list_battletag_info()

    all
    |> Enum.filter(& &1.battletag_short)
    |> Enum.group_by(& &1.battletag_short)
    |> add_max(table)

    all
    |> Enum.filter(& &1.battletag_full)
    |> Enum.group_by(& &1.battletag_full)
    |> add_max(table)
  end

  defp add_max(grouped, table) do
    grouped
    |> Enum.each(fn {bt, list} ->
      max = list |> Enum.max_by(& &1.priority)
      :ets.insert(table, {bt, max})
    end)
  end

  @spec get_long_or_short([String.t()] | String.t()) :: Battletag.t() | nil
  def get_long_or_short(list) when is_list(list), do: list |> Enum.find(nil, &get_long_or_short/1)

  def get_long_or_short(bt) when is_binary(bt) do
    full = get(bt)

    shortened =
      with nil <- bt |> InvitedPlayer.shorten_battletag() |> get() do
        bt |> InvitedPlayer.shorten_battletag() |> Backend.MastersTour.name_hacks() |> get
      end

    {full, shortened}

    case {full, shortened} do
      {nil, s} -> s
      {f, nil} -> f
      {%{priority: fp}, s = %{priority: sp}} when fp < 5000 and sp >= 5000 -> s
      {f, _} -> f
    end
  end

  def get_long_or_short(_), do: nil

  @spec get([String.t()] | String.t()) :: Battletag.t() | nil
  def get(list) when is_list(list), do: list |> Enum.find(nil, &get/1)
  def get(bt) when is_binary(bt), do: table() |> Util.ets_lookup(bt)

  def table(), do: :ets.whereis(@name)

  def update_cache(ret = {:error, _}), do: ret

  def update_cache(ret = {:ok, bt}) do
    GenServer.cast(@name, {:update_cache, bt})
    ret
  end

  def update_cache(), do: GenServer.cast(@name, :update_cache)

  def handle_cast({:update_cache, bt = %{priority: priority}}, state = %{table: table}) do
    [bt.battletag_full, bt.battletag_short]
    |> Enum.filter(fn b ->
      table
      |> Util.ets_lookup(b)
      |> case do
        %{priority: p} when p > priority -> false
        _ -> true
      end
    end)
    |> Enum.each(fn b ->
      table
      |> :ets.insert({b, bt})
    end)

    {:noreply, state}
  end

  def handle_cast(:update_cache, state = %{table: table}) do
    table |> update_table()
    {:noreply, state}
  end

  def handle_info(:update_cache, state = %{table: table}) do
    table |> update_table()
    {:noreply, state}
  end
end
