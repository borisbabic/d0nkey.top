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
    base_criteria = [{"period", "past_2_weeks"}]

    for {_, format, _} <- Hearthstone.Enums.Format.all() do
      key = format_key(format)

      DeckTracker.archetypes([{"format", format} | base_criteria])
      |> insert_archetypes(table, key)
    end

    key = format_key("all")

    DeckTracker.archetypes(base_criteria)
    |> insert_archetypes(table, key)
  end

  defp insert_archetypes(archetypes, table, key) do
    :ets.insert(table, {key, archetypes})
  end

  defp format_key(format), do: "format_#{format}"

  def get_archetypes(format \\ "all") when is_binary(format) or is_integer(format) do
    key = format_key(format)
    table() |> Util.ets_lookup(key)
  end

  def update(), do: GenServer.cast(__MODULE__, :update)

  def handle_cast(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  def table(), do: :ets.whereis(__MODULE__)
end
