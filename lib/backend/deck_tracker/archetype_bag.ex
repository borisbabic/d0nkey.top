defmodule Hearthstone.DeckTracker.ArchetypeBag do
  @doc "holds archetypes used for filtering"
  use GenServer
  alias Hearthstone.DeckTracker

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(__MODULE__, [:named_table])
    {:ok, %{table: table}, {:continue, :update}}
  end

  def handle_continue(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  defp update_table(table) do
    all_archetypes =
      Enum.flat_map(Hearthstone.Enums.Format.all(), fn {format, _} ->
        key = format_key(format)
        archetypes = DeckTracker.currently_aggregated_archetypes(format)

        insert_archetypes(archetypes, table, key)
        archetypes
      end)
      |> Enum.uniq()

    key = format_key("all")
    insert_archetypes(all_archetypes, table, key)
  end

  defp insert_archetypes(archetypes, table, key) do
    :ets.insert(table, {key, archetypes})
  end

  defp format_key(format), do: "format_#{format}"

  def get_archetypes(format \\ "all") when is_binary(format) or is_integer(format) do
    key = format_key(format)
    Util.ets_lookup(table(), key) || []
  end

  def update(), do: GenServer.cast(__MODULE__, :update)

  def handle_cast(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  def table(), do: :ets.whereis(__MODULE__)
end
