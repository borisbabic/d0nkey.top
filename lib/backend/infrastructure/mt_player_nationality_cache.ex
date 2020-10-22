defmodule Backend.Infrastructure.PlayerNationalityCache do
  @moduledoc false
  use GenServer
  alias Backend.MastersTour.InvitedPlayer
  @name :mt_player_nationality_cache
  @type state :: {%{}, %{}}

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def get_country(mt_bt) do
    GenServer.call(@name, {:get_country, mt_bt})
  end

  def get(mt_bt) do
    GenServer.call(@name, {:get, mt_bt})
  end

  def reinit(all) do
    GenServer.cast(@name, {:init, all})
  end

  def init(_args) do
    {:ok, {%{}, %{}}}
  end

  defp init_state(all) do
    all
    |> Enum.reduce({%{}, %{}}, fn pn, {mt_bt_map, short_bt_map} ->
      {
        mt_bt_map |> Map.put(pn.mt_battletag_full, pn),
        short_bt_map |> Map.put(pn.mt_battletag_full |> InvitedPlayer.shorten_battletag(), pn)
      }
    end)
  end

  defp get_country(map, key) do
    p = Map.get(map, key)

    if p && p.nationality do
      p.nationality
    else
      nil
    end
  end

  def handle_call({:get_country, mt_bt}, _from, state = {mt_bt_map, short_bt_map}) do
    response =
      get_country(mt_bt_map, mt_bt) ||
        get_country(short_bt_map, mt_bt |> InvitedPlayer.shorten_battletag())

    {:reply, response, state}
  end

  def handle_call({:get, mt_bt}, _from, state = {mt_bt_map, short_bt_map}) do
    response =
      with nil <- Map.get(mt_bt_map, mt_bt),
           nil <- Map.get(short_bt_map, mt_bt |> InvitedPlayer.shorten_battletag()) do
        nil
      else
        pn = %{nationality: _} -> pn
        _ -> nil
      end

    {:reply, response, state}
  end

  def handle_cast({:init, all}, _state) do
    {:noreply, init_state(all)}
  end
end
