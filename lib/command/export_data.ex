defmodule Command.ExportData do
  @moduledoc "Commands for exporting sql data to CSV for importing on dev machine"
  @type export_games_params :: %{
          optional(:start_time) => NaiveDateTime.t(),
          optional(:end_time) => NaiveDateTime.t(),
          optional(:file_part) => String.t(),
          optional(:directory) => String.t(),
          optional(:delimiter) => String.t()
        }
  @type import_params :: %{
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
    export_played_cards(params)
  end

  @spec fill_export_games_params(export_games_params()) :: export_games_params()
  def fill_export_games_params(params \\ %{}) do
    start_time = Map.get(params, :start_time) || yesterday_start()

    %{
      start_time: start_time,
      end_time: Map.get(params, :end_time) || NaiveDateTime.utc_now(),
      file_part: Map.get(params, :file_part) || start_time |> Timex.to_date() |> to_string(),
      format: Map.get(params, :format, 2) |> Util.to_int_or_orig(),
      directory: Map.get(params, :directory, "/tmp") |> String.trim_trailing("/"),
      delimiter: Map.get(params, :delimiter, "|")
    }
  end

  def fill_import_params(params \\ %{}) do
    file_part = Map.get(params, :file_part) || yesterday_start() |> Timex.to_date() |> to_string()

    %{
      file_part: file_part,
      directory: Map.get(params, :directory, "/tmp"),
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

  def export_played_cards(params) do
    sql = export_played_cards_sql(params)
    IO.puts("Exporting Played Games...")
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
        format: format,
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
              AND DTG.FORMAT = #{format}
          )
      ) TO '#{directory}/decks_#{file_part}.csv' DELIMITER '#{delimiter}' CSV HEADER;
    """
  end

  def export_games_sql(%{
        start_time: start_time,
        end_time: end_time,
        directory: directory,
        delimiter: delimiter,
        format: format,
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
              AND DTG.FORMAT = #{format}
          )
      ) TO '#{directory}/games_#{file_part}.csv' DELIMITER '#{delimiter}' CSV HEADER;
    """
  end

  def export_tallies_sql(%{
        start_time: start_time,
        end_time: end_time,
        directory: directory,
        delimiter: delimiter,
        format: format,
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
            AND DTG.FORMAT = #{format}
        )
    ) TO '#{directory}/tallies_#{file_part}.csv' DELIMITER '#{delimiter}' CSV HEADER;
    """
  end

  def export_played_cards_sql(%{
        start_time: start_time,
        end_time: end_time,
        directory: directory,
        delimiter: delimiter,
        format: format,
        file_part: file_part
      }) do
    """
    COPY (
      SELECT
        *
      FROM
        PUBLIC.dt_game_played_cards PLAYED_CARDS
      WHERE
        PLAYED_CARDS.GAME_ID IN (
          SELECT DISTINCT
            DTG.ID
          FROM
            PUBLIC.DT_GAMES DTG
            INNER JOIN PUBLIC.DECK D ON D.ID = DTG.PLAYER_DECK_ID
          WHERE
            DTG.INSERTED_AT >= '#{start_time}'
            AND DTG.INSERTED_AT < '#{end_time}'
            AND DTG.GAME_TYPE = 7
            AND DTG.FORMAT = #{format}
        )
    ) TO '#{directory}/played_cards_#{file_part}.csv' DELIMITER '#{delimiter}' CSV HEADER;
    """
  end

  defp yesterday_start() do
    Timex.today() |> Timex.add(Timex.Duration.from_days(-1)) |> Timex.to_datetime()
  end

  defp plus_one_day(start) do
    Timex.add(start, Timex.Duration.from_days(1))
  end

  def import(params \\ %{}) do
    params = fill_import_params(params)
    import_csv(params, "sources", "public.dt_sources")
    import_csv(params, "decks", "public.deck")
    import_csv(params, "games", "public.dt_games")
    import_csv(params, "tallies", "public.dt_card_game_tally")
    import_csv(params, "played_cards", "public.dt_game_played_cards")
  end

  def import_csv(params, table, target_table) do
    file = "#{params.directory}/#{table}_#{params.file_part}.csv"
    stream = File.stream!(file)
    temporary_table_name = "temporary_#{table}_#{params.file_part}"

    create_temporary = """
    CREATE TEMPORARY TABLE "#{temporary_table_name}" (LIKE #{target_table} INCLUDING ALL) ON COMMIT DROP;
    """

    copy_statement = """
      COPY "#{temporary_table_name}" FROM stdin WITH (FORMAT csv, DELIMITER '#{params.delimiter}', HEADER true)
    """

    insert_into_statement = """
      INSERT INTO #{target_table}
      SELECT * FROM "#{temporary_table_name}"
      ON CONFLICT DO NOTHING;
    """

    Backend.Repo.transact(
      fn repo ->
        repo.query!(create_temporary)

        stream
        |> Stream.chunk_every(2000, 2000, [])
        |> Stream.into(Ecto.Adapters.SQL.stream(repo, copy_statement))
        |> Stream.run()

        repo.query!(insert_into_statement)
        {:ok, :ok}
      end,
      timeout: :infinity
    )
  end
end
