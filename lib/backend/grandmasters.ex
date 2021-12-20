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
    update()
    {:ok, %{table: table}}
  end

  def table(), do: :ets.whereis(@name)

  def update(), do: GenServer.cast(@name, :update)

  def handle_cast(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  defp update_table(table) do
    # with {:ok, response} <- Communicator.get_gm() do
    #   update_table(response, table)
    # end
  end

  defp update_table(response, table) do
    total_results =
      response
      |> Response.stage_titles()
      |> Enum.map(fn stage ->
        results = response |> Response.results(stage) |> hack_results(response, stage)
        :ets.insert(table, {results_key(stage), sort_results(results)})

        Task.start(fn ->
          response |> LineupFetcher.save_lineups(stage)
        end)

        results
      end)
      |> Enum.reduce(%{}, fn weekly_results, carry ->
        weekly_results
        |> Enum.map(fn {player, points} ->
          {player, %{points: points, results: [points]}}
        end)
        |> Map.new()
        |> Map.merge(carry, fn _, first, second ->
          new_points = first.points + second.points
          new_results = (first.results ++ second.results) |> Enum.sort(:desc)
          %{points: new_points, results: new_results}
        end)
      end)
      |> add_season_winner_points(response)
      |> Enum.sort_by(&elem(&1, 1).results, :desc)
      |> Enum.sort_by(&elem(&1, 1).points, :desc)
      |> Enum.map(fn {player, %{points: points}} ->
        {player, points}
      end)

    set_brackets(response, table)
    competitors = response |> Response.regionified_competitors()
    :ets.insert(table, {"regionified_competitors", competitors})
    :ets.insert(table, {"total_results", total_results})
    :ets.insert(table, {"raw_response", response})
  end

  {2021, 20}

  def add_season_winner_points(results_map, %{requested_season: %{year: 2021, season: 2}}) do
    ["Frenetic", "Posesi", "Nalguidan"]
    |> Enum.reduce(results_map, fn prev_winner, r ->
      Map.update!(r, prev_winner, &add_winner_points/1)
    end)
  end
  def add_season_winner_points(results_map, _), do: results_map

  def add_winner_points(%{points: p, results: r}), do: %{points: p + 5, results: r}

  defp set_brackets(response, table) do
    response
    |> Response.brackets()
    |> Enum.each(fn b ->
      key = bracket_key(b)
      :ets.insert(table, {key, b})
    end)
  end

  def bracket_key(%{id: id}), do: bracket_key(id)
  def bracket_key(bracket_id), do: "bracekt_id_#{bracket_id}"

  defp sort_results(results), do: results |> Enum.sort_by(&elem(&1, 1), :desc)
  defp results_key(stage), do: "results_#{stage}"

  def bracket(bracket_id) do
    key = bracket_key(bracket_id)

    table()
    |> Util.ets_lookup(key)
  end

  def results(stage) do
    key = results_key(stage)

    table()
    |> Util.ets_lookup(key, %{})
  end

  defp hack_results(results, %{requested_season: %{season: 1, year: 2021}}, "Week 4") do
    results |> Map.put("Fled", 3)
  end

  defp hack_results(results, _, _), do: results

  def raw_response(), do: table() |> Util.ets_lookup("raw_response", %{})
  def total_results(), do: table() |> Util.ets_lookup("total_results", %{})

  def regionified_competitors(), do: table() |> Util.ets_lookup("regionified_competitors", [])

  defp competitors_map() do
    regionified_competitors()
    |> Enum.flat_map(fn {region, competitors} ->
      competitors |> Enum.map(&{&1.name, region})
    end)
    |> Map.new()
  end

  def regionify_results(results) do
    competitors_map = competitors_map()

    results
    |> Enum.group_by(fn {comp, _results} ->
      competitors_map |> Map.get(comp)
    end)
  end

  def region_matches(region, stage) do
    raw_response()
    |> Response.matches(stage)
    |> Enum.filter(&(&1.competitors |> Enum.any?()))
    |> regionify_matches()
    |> Map.get(region, %{})
  end

  defp regionify_matches(matches) do
    competitors_map = competitors_map()

    matches
    |> Enum.group_by(fn %{competitors: c} ->
      name = c |> Enum.find_value(&(&1 && &1.name))
      competitors_map |> Map.get(name)
    end)
  end

  def region_results(region) do
    total_results()
    |> regionify_results()
    |> Map.get(region, %{})
  end

  def region_results(region, stage) do
    stage
    |> results()
    |> regionify_results()
    |> Map.get(region, %{})
  end

  def get_points(results, gm, default \\ 0)

  def get_points(results, gm, default) when is_list(results) do
    results
    |> List.keyfind(gm, 0)
    |> case do
      {^gm, points} -> points
      _ -> default
    end
  end

  def get_points(_, _, default), do: default

  def parse_region(region, default \\ :EU) do
    region
    |> to_string()
    |> case do
      "APAC" -> :APAC
      "AP" -> :APAC
      "EU" -> :EU
      "NA" -> :NA
      "US" -> :NA
      "AM" -> :NA
      _ -> default
    end
  end
end
