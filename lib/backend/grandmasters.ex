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

  def update(), do: GenServer.cast(@name, :update)

  def handle_cast(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  defp update_table(table), do: Communicator.get_gm() |> update_table(table)

  defp update_table(response, table) do
    total_results =
      response
      |> Response.stage_titles()
      |> Enum.map(fn stage ->
        results = response |> Response.results(stage) |> hack_results(response, stage)
        :ets.insert(table, {results_key(stage), results})

        Task.start(fn ->
          response |> LineupFetcher.save_lineups(stage)
        end)

        results
      end)
      |> Enum.reduce(%{}, fn weekly_results, carry ->
        weekly_results
        |> Map.merge(carry, fn _, first, second ->
          first + second
        end)
      end)
      |> Enum.sort_by(&elem(&1, 1), :desc)

    competitors = response |> Response.regionified_competitors()
    :ets.insert(table, {"regionified_competitors", competitors})
    :ets.insert(table, {"total_results", total_results})
    :ets.insert(table, {"raw_response", response})
  end

  defp results_key(stage), do: "results_#{stage}"

  def results(stage) do
    key = results_key(stage)

    table()
    |> Util.ets_lookup(key, %{})
  end

  defp hack_results(results, %{requested_season: %{season: 1, year: 2021}}, "Week 4") do
    results |> Map.put("Fled", 3)
  end

  defp hack_results(results, _, _), do: results

  def total_results(), do: table() |> Util.ets_lookup("total_results", %{})

  def regionified_competitors(), do: table() |> Util.ets_lookup("regionified_competitors", [])

  def regionify_results(results) do
    competitors_map =
      regionified_competitors
      |> Enum.flat_map(fn {region, competitors} ->
        competitors |> Enum.map(&{&1.name, region})
      end)
      |> Map.new()

    results
    |> Enum.group_by(fn {comp, _results} ->
      competitors_map |> Map.get(comp)
    end)
  end
end
