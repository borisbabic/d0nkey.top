defmodule Backend.Tournaments.HSEsports do
  @moduledoc """
  In-memory store and manager for Hearthstone Esports tournaments (e.g. World Championship 2026).
  Polls an external CSV every 2 minutes when auto_update is enabled in production.
  """
  use GenServer
  require Logger

  alias Backend.Tournaments.HSEsports.Tournament
  alias Backend.Tournaments.HSEsports.Parser
  alias Backend.Hearthstone
  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.Match, as: BracketMatch
  alias Backend.BracketPredictions.FuzzyMatcher
  alias Backend.Repo

  @table :hsesports_tournaments
  # 2 minutes
  @poll_interval 120_000
  @default_id "wc_2026"

  # --- Client API ---

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Returns the in-memory tournament struct.
  """
  @spec get_tournament(String.t()) :: Tournament.t() | nil
  def get_tournament(tournament_id \\ @default_id) do
    case :ets.lookup(@table, tournament_id) do
      [{^tournament_id, %Tournament{} = t}] ->
        t

      _ ->
        if GenServer.whereis(__MODULE__) do
          GenServer.call(__MODULE__, {:get_tournament, tournament_id})
        else
          nil
        end
    end
  rescue
    _ ->
      if GenServer.whereis(__MODULE__) do
        GenServer.call(__MODULE__, {:get_tournament, tournament_id})
      else
        nil
      end
  end

  @doc """
  Returns all groups for the tournament.
  """
  def get_groups(tournament_id \\ @default_id) do
    case get_tournament(tournament_id) do
      %Tournament{groups: groups} -> groups
      _ -> []
    end
  end

  @doc """
  Returns playoff matches for the tournament.
  """
  def get_playoffs(tournament_id \\ @default_id) do
    case get_tournament(tournament_id) do
      %Tournament{playoffs: playoffs} -> playoffs
      _ -> []
    end
  end

  @doc """
  Returns match stats for archetype calculation.
  """
  @spec match_stats(String.t()) :: {:ok, [Backend.Tournaments.MatchStats.t()]} | {:error, any()}
  def match_stats(tournament_id \\ @default_id) do
    case get_tournament(tournament_id) do
      %Tournament{match_stats: stats} -> {:ok, stats}
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Loads and parses CSV text directly into memory.
  """
  def load_csv(csv_text, tournament_id \\ @default_id) do
    GenServer.call(__MODULE__, {:load_csv, csv_text, tournament_id})
  end

  @doc """
  Loads and parses CSV from a local file path.
  """
  def load_file(file_path, tournament_id \\ @default_id) do
    GenServer.call(__MODULE__, {:load_file, file_path, tournament_id})
  end

  @doc """
  Manually triggers a CSV fetch, in-memory update, and bracket prediction sync.
  """
  def poll do
    GenServer.call(__MODULE__, :poll)
  end

  @doc """
  Syncs in-memory parsed tournament results to a bracket prediction tournament in the DB.
  """
  def sync_bracket_prediction(prediction_id \\ nil, tournament_id \\ @default_id) do
    id = prediction_id || bracket_prediction_id()

    if id do
      GenServer.call(__MODULE__, {:sync_bracket_prediction, id, tournament_id})
    else
      {:error, :no_prediction_id_configured}
    end
  end

  # --- Configuration Helpers ---

  def config do
    Application.get_env(:backend, __MODULE__, [])
  end

  def auto_update? do
    Keyword.get(config(), :auto_update, false) and not is_nil(csv_url()) and csv_url() != ""
  end

  def csv_url do
    Keyword.get(config(), :csv_url) || System.get_env("WC_2026_CSV_URL")
  end

  def bracket_prediction_id do
    case Keyword.get(config(), :bracket_prediction_id) || System.get_env("WC_2026_BRACKET_PREDICTION_ID") do
      nil -> nil
      "" -> nil
      id when is_integer(id) -> id
      id when is_binary(id) -> Util.to_int(id, nil)
    end
  end

  # --- GenServer Callbacks ---

  @impl true
  def init(_opts) do
    ensure_table_exists()

    initial_tournament = default_empty_tournament()
    store_tournament(initial_tournament)

    url = csv_url()

    if url && url != "" do
      send(self(), :initial_fetch)
    else
      Logger.info("[HSEsports] No CSV URL configured, initialized with empty tournament")
    end

    {:ok, %{current_tournament: initial_tournament}}
  end

  @impl true
  def handle_call({:get_tournament, id}, _from, state) do
    t =
      case :ets.lookup(@table, id) do
        [{^id, %Tournament{} = found}] -> found
        _ -> if state.current_tournament && state.current_tournament.id == id, do: state.current_tournament, else: nil
      end

    {:reply, t, state}
  end

  @impl true
  def handle_call({:load_csv, csv_text, id}, _from, state) do
    case parse_and_build(csv_text, id) do
      {:ok, tournament} ->
        store_tournament(tournament)

        new_state =
          if id == @default_id or is_nil(state.current_tournament) do
            %{state | current_tournament: tournament}
          else
            state
          end

        {:reply, {:ok, tournament}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:load_file, file_path, id}, _from, state) do
    case File.read(file_path) do
      {:ok, content} ->
        case parse_and_build(content, id) do
          {:ok, tournament} ->
            store_tournament(tournament)

            new_state =
              if id == @default_id or is_nil(state.current_tournament) do
                %{state | current_tournament: tournament}
              else
                state
              end

            {:reply, {:ok, tournament}, new_state}

          {:error, reason} ->
            {:reply, {:error, reason}, state}
        end

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call(:poll, _from, state) do
    new_state = do_fetch_and_update(state)
    {:reply, {:ok, new_state.current_tournament}, new_state}
  end

  @impl true
  def handle_call({:sync_bracket_prediction, prediction_id, tournament_id}, _from, state) do
    tournament = get_tournament(tournament_id) || state.current_tournament
    result = do_sync_bracket_prediction(tournament, prediction_id)
    {:reply, result, state}
  end

  @impl true
  def handle_info(:initial_fetch, state) do
    new_state = do_fetch_and_update(state)

    if auto_update?() do
      Logger.info("[HSEsports] Auto-update enabled for URL: #{csv_url()}, polling every 2 minutes")
      schedule_next_poll()
    else
      Logger.info("[HSEsports] Auto-update disabled, fetched CSV once from #{csv_url()}")
    end

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:poll, state) do
    new_state = do_fetch_and_update(state)

    if auto_update?() do
      schedule_next_poll()
    end

    {:noreply, new_state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # --- Internal Helpers ---

  defp ensure_table_exists do
    if :ets.info(@table) == :undefined do
      :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])
    end
  end

  defp store_tournament(%Tournament{id: id} = tournament) do
    ensure_table_exists()
    :ets.insert(@table, {id, tournament})
  end

  defp store_tournament(_), do: :ok

  defp default_empty_tournament do
    %Tournament{
      id: @default_id,
      name: "Hearthstone World Championship 2026",
      start_time: ~N[2026-09-08 16:00:00],
      tags: [:bo5],
      groups: [],
      playoffs: [],
      matches: [],
      match_stats: [],
      last_updated_at: DateTime.utc_now()
    }
  end

  defp schedule_next_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp do_fetch_and_update(state) do
    url = csv_url()

    if url && url != "" do
      Logger.info("[HSEsports] Fetching CSV from #{url}...")

      case Req.get(url, receive_timeout: 15_000) do
        {:ok, %{status: 200, body: body}} when is_binary(body) and body != "" ->
          case parse_and_build(body, @default_id) do
            {:ok, tournament} ->
              Logger.info("[HSEsports] Successfully updated tournament state from #{url}")
              store_tournament(tournament)

              # Maybe sync bracket prediction
              pred_id = bracket_prediction_id()

              if pred_id do
                do_sync_bracket_prediction(tournament, pred_id)
              end

              %{state | current_tournament: tournament}

            {:error, reason} ->
              Logger.error("[HSEsports] Failed to parse CSV from #{url}: #{inspect(reason)}")
              state
          end

        other ->
          Logger.warning("[HSEsports] Unexpected response fetching CSV from #{url}: #{inspect(other)}")
          state
      end
    else
      state
    end
  rescue
    e ->
      Logger.error("[HSEsports] Exception while fetching CSV: #{inspect(e)}")
      state
  end

  defp parse_and_build(csv_text, tournament_id) do
    lineups =
      try do
        Hearthstone.get_lineups(tournament_id, "hsesports")
      rescue
        _ -> []
      end

    case Parser.parse(csv_text, lineups) do
      {:ok, parsed} ->
        tournament = %Tournament{
          id: tournament_id,
          name: "Hearthstone World Championship 2026",
          start_time: ~N[2026-09-08 16:00:00],
          tags: [:bo5],
          groups: parsed.groups,
          playoffs: parsed.playoffs,
          matches: parsed.matches,
          match_stats: parsed.match_stats,
          raw_csv: csv_text,
          last_updated_at: DateTime.utc_now()
        }

        {:ok, tournament}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_sync_bracket_prediction(nil, _), do: {:error, :no_tournament_state}

  defp do_sync_bracket_prediction(%Tournament{matches: parsed_matches}, prediction_id) do
    Logger.info("[HSEsports] Syncing results to bracket prediction tournament #{prediction_id}...")

    case BracketPredictions.get_tournament(prediction_id) do
      nil ->
        Logger.warning("[HSEsports] Bracket prediction tournament #{prediction_id} not found")
        {:error, :tournament_not_found}

      pred_tour ->
        pred_tour = Repo.preload(pred_tour, stages: :matches)
        mappings = pred_tour.participant_mappings || %{}
        db_matches = pred_tour.matches || []

        parsed_by_id = Map.new(parsed_matches, &{&1.match_identifier, &1})

        updated_count =
          Enum.reduce(db_matches, 0, fn db_match, acc ->
            case Map.get(parsed_by_id, db_match.match_identifier) do
              nil ->
                acc

              pm ->
                top = FuzzyMatcher.resolve_name(pm.top_name, mappings) || db_match.top_name
                bottom = FuzzyMatcher.resolve_name(pm.bottom_name, mappings) || db_match.bottom_name
                winner = FuzzyMatcher.resolve_name(pm.actual_winner_name, mappings)

                changes =
                  %{
                    top_name: top,
                    bottom_name: bottom,
                    top_score: pm.top_score,
                    bottom_score: pm.bottom_score,
                    actual_winner_name: winner,
                    is_complete: pm.is_complete
                  }

                # Only update if changed
                if match_changed?(db_match, changes) do
                  db_match
                  |> BracketMatch.changeset(changes)
                  |> Repo.update()
                  |> case do
                    {:ok, _} -> acc + 1
                    _ -> acc
                  end
                else
                  acc
                end
            end
          end)

        if updated_count > 0 do
          Logger.info("[HSEsports] Updated #{updated_count} matches. Propagating and recalculating leaderboard...")
          BracketPredictions.propagate_actual_results(pred_tour.id)
          BracketPredictions.recalculate_leaderboard(pred_tour.id)
        end

        {:ok, updated_count}
    end
  rescue
    e ->
      Logger.error("[HSEsports] Failed to sync bracket prediction: #{inspect(e)}")
      {:error, e}
  end

  defp match_changed?(db_match, changes) do
    (changes.top_name && changes.top_name != db_match.top_name) ||
      (changes.bottom_name && changes.bottom_name != db_match.bottom_name) ||
      changes.top_score != db_match.top_score ||
      changes.bottom_score != db_match.bottom_score ||
      changes.actual_winner_name != db_match.actual_winner_name ||
      changes.is_complete != db_match.is_complete
  end
end
