defmodule Backend.UserManagerIconBag do
  @moduledoc """
  Holds cached player icons
  """
  use GenServer
  @name :player_icon_cache
  @picture_icons [
    {"D0nkey#2470", {:image, "/favicon.ico"}},
    # {"Blastoise#1855", {:image, "/images/icons/blastoise.png"}},
    {"Faeli#2572", {:image, "/images/icons/faeli.png"}},
    {"RHat#1215", {:image, "/images/icons/rhat.png"}},
    # {"BruTo#21173", {:image, "/images/icons/bruto.png"}},
    # {"Dragoninja#1573", {:image, "/images/icons/dragoninja.png"}},
    {"Ajani#2766", {:image, "/images/icons/ajani.jpg"}}
  ]
  @type player_icon :: {:image, String.t()} | {:unicode, String.t()}

  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.UserManager.User
  alias Backend.Battlenet.Battletag

  def start_link(default), do: GenServer.start_link(__MODULE__, default, name: @name)

  def init(_args) do
    table = :ets.new(@name, [:named_table])
    update_table(table)
    {:ok, %{table: table}}
  end

  defp update_table(table) do
    query =
      from u in User,
        where: not is_nil(u.unicode_icon),
        select: u

    unicode_icons =
      Repo.all(query)
      |> Enum.map(&{&1.battletag, {:unicode, &1.unicode_icon}})

    set_icons(@picture_icons, table)
    set_icons(unicode_icons, table)
  end

  def set_icons(icons, table) do
    icons
    |> Enum.each(fn {btag, icon_config} ->
      set_icon(table, btag, icon_config)
    end)
  end

  def update(), do: GenServer.cast(@name, :update)

  def set_user_icons(%{battletag: btag, unicode_icon: nil}) do
    GenServer.cast(@name, {:delete_icon, btag})
  end

  def set_user_icons(%{battletag: btag, unicode_icon: icon}) do
    GenServer.cast(@name, {:set_icon, {btag, {:unicode, icon}}})
  end

  def set_user_icons(_), do: nil

  def handle_cast(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  def handle_cast({:set_icon, {btag, icon}}, state = %{table: table}) do
    set_icon(table, btag, icon)
    {:noreply, state}
  end

  def handle_cast({:delete_icon, btag}, state = %{table: table}) do
    delete_icon(table, btag)
    {:noreply, state}
  end

  @spec set_icon(any(), String.t(), player_icon()) :: any()
  def set_icon(table, btag, icon) do
    :ets.insert(table, {btag, icon})
    :ets.insert(table, {Battletag.shorten(btag), icon})
  end

  def delete_icon(table, btag) do
    :ets.delete(table, btag)
    :ets.delete(table, Battletag.shorten(btag))
  end

  def table(), do: :ets.whereis(@name)

  def get(player) do
    table = table()

    with [] <- :ets.lookup(table, player),
         [] <- :ets.lookup(table, Battletag.shorten(player)) do
      nil
    else
      [{_, value}] -> value
      other -> other
    end
  end
end
