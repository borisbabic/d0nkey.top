defmodule Backend.Grandmasters do
  @moduledoc false

  use GenServer
  alias Backend.Grandmasters.Response
  alias Backend.Infrastructure.GrandmastersCommunicator, as: Communicator
  alias Backend.Grandmasters.LineupFetcher

  @name :grandmasters

  def start_link(default), do: GenServer.start_link(__MODULE__, default, name: @name)

  def init(_args) do
    table = :ets.new(@name, [:named_table])
    update_table(table)
    {:ok, %{table: table}}
  end

  def table(), do: :ets.whereis(@name)

  defp update_table(table), do: Communicator.get_gm() |> update_table(table)

  defp update_table(response, table) do
    response
    |> Response.stage_titles()
    |> Enum.each(fn stage ->
      results = response |> Response.results(stage)
      :ets.insert(table, {results_key(stage), results})

      Task.start(fn ->
        response |> LineupFetcher.save_lineups(stage)
      end)
    end)

    :ets.insert(table, {"raw_response", response})
  end

  defp results_key(stage), do: "results_#{stage}"

  def results(stage) do
    key = results_key(stage)

    table()
    |> Util.ets_lookup(key, [])
  end
end
