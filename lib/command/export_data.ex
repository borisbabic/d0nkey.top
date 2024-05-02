defmodule Command.ExportData do
  @moduledoc "Commands for exporting sql data to CSV for importing on dev machine"
  @type export_games_params :: %{
          optional(:start_time) => NaiveDateTime.t(),
          optional(:end_time) => NaiveDateTime.t(),
          optional(:file_part) => String.t(),
          optional(:directory) => String.t(),
          optional(:delimiter) => String.t()
        }
  @spec export_games_data(export_games_params()) :: any()
  def export_games_data(params \\ %{}) do
    params = fill_export_games_params(params)
    export_sources(params)
    export_decks(params)
    export_games(params)
    export_tallies(params)
  end

  @spec fill_export_games_params(export_games_params()) :: export_games_params()
  def fill_export_games_params(params \\ %{}) do
    start_time = Map.get(params, :start_time) || yesterday_start()

    %{
      start_time: start_time,
      end_time: Map.get(params, :end_time) || start_time |> plus_one_day(),
      file_part: Map.get(params, :file_part) || start_time |> Timex.to_date() |> to_string(),
      directory:
        Map.get(params, :directory, "/mnt/storage_box/dbdumps") |> String.trim_trailing("/"),
      delimiter: Map.get(params, :delimiter, "|")
    }
  end

  def export_sources(params) do
    sql = export_sources_sql(params)
    IO.puts("Exporting Sources...")
    IO.puts(sql)
    Backend.Repo.query!(sql, [], timeout: :infinity)
  end

  def export_decks(params) do
    sql = export_decks_sql(params)
    IO.puts("Exporting Decks...")
    IO.puts(sql)
    Backend.Repo.query!(sql, [], timeout: :infinity)
  end

  def export_games(params) do
    sql = export_games_sql(params)
    IO.puts("Exporting Games...")
    IO.puts(sql)
    Backend.Repo.query!(sql, [], timeout: :infinity)
  end

  def export_tallies(params) do
    sql = export_tallies_sql(params)
    IO.puts("Exporting Tallies...")
    IO.puts(sql)
    Backend.Repo.query!(sql, [], timeout: :infinity)
  end

  def export_sources_sql(%{directory: directory, delimiter: delimiter, file_part: file_part}) do
    """
    COPY (
      SELECT
        *
      FROM
        public.dt_sources
      WHERE
        id > 0
    ) TO '#{directory}/sources_#{file_part}.csv' DELIMITER '#{delimiter}' CSV HEADER;
    """
  end

  def export_decks_sql(%{
        start_time: start_time,
        end_time: end_time,
        directory: directory,
        delimiter: delimiter,
        file_part: file_part
      }) do
    """
      COPY (
        SELECT
          *
        FROM
          PUBLIC.DECK
        WHERE
          ID IN (
            SELECT DISTINCT
              D.ID
            FROM
              PUBLIC.DT_GAMES DTG
              INNER JOIN PUBLIC.DECK D ON D.ID = DTG.PLAYER_DECK_ID
            WHERE
              DTG.INSERTED_AT >= '#{start_time}'
              AND DTG.INSERTED_AT < '#{end_time}'
              AND DTG.GAME_TYPE = 7
              AND DTG.FORMAT = 2
              AND D.SIDEBOARDS IS NULL
          )
      ) TO '#{directory}/decks_#{file_part}.csv' DELIMITER '#{delimiter}' CSV HEADER;
    """
  end

  def export_games_sql(%{
        start_time: start_time,
        end_time: end_time,
        directory: directory,
        delimiter: delimiter,
        file_part: file_part
      }) do
    """
      COPY (
        SELECT
          *
        FROM
          PUBLIC.DT_GAMES DTG
        WHERE
          ID IN (
            SELECT DISTINCT
              DTG.ID
            FROM
              PUBLIC.DT_GAMES DTG
              INNER JOIN PUBLIC.DECK D ON D.ID = DTG.PLAYER_DECK_ID
            WHERE
              DTG.INSERTED_AT >= '#{start_time}'
              AND DTG.INSERTED_AT < '#{end_time}'
              AND DTG.GAME_TYPE = 7
              AND DTG.FORMAT = 2
              AND D.SIDEBOARDS IS NULL
          )
      ) TO '#{directory}/games_#{file_part}.csv' DELIMITER '#{delimiter}' CSV HEADER;
    """
  end

  def export_tallies_sql(%{
        start_time: start_time,
        end_time: end_time,
        directory: directory,
        delimiter: delimiter,
        file_part: file_part
      }) do
    """
    COPY (
      SELECT
        *
      FROM
        PUBLIC.DT_CARD_GAME_TALLY TALLY
      WHERE
        TALLY.GAME_ID IN (
          SELECT DISTINCT
            DTG.ID
          FROM
            PUBLIC.DT_GAMES DTG
            INNER JOIN PUBLIC.DECK D ON D.ID = DTG.PLAYER_DECK_ID
          WHERE
            DTG.INSERTED_AT >= '#{start_time}'
            AND DTG.INSERTED_AT < '#{end_time}'
            AND DTG.GAME_TYPE = 7
            AND DTG.FORMAT = 2
            AND D.SIDEBOARDS IS NULL
        )
    ) TO '#{directory}/tallies_#{file_part}.csv' DELIMITER '#{delimiter}' CSV HEADER;
    """
  end

  defp yesterday_start() do
    Timex.today() |> Timex.add(Timex.Duration.from_days(-1)) |> Timex.to_datetime()
  end

  defp plus_one_day(start) do
    Timex.add(start, Timex.Duration.from_days(1))
  end
end
