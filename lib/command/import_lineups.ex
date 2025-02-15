defmodule Command.ImportLineups do
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Hearthstone.DeckcodeExtractor
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck

  use Tesla
  plug Tesla.Middleware.FollowRedirects, max_redirects: 3

  def import_from_battlefy_csv_url(csv_url, tournament_id, class_num) do
    %{body: body} = HTTPoison.get!(csv_url, [], follow_redirect: true)

    body
    |> parse_body()
    |> import_battlefy(tournament_id, class_num)
  end

  def import_battlefy(data, tournament_id, class_num) do
    Enum.map(data, fn [battletag | rest] ->
      decks = Enum.drop(rest, class_num + 1)
      [battletag | decks]
    end)
    |> import(tournament_id, "battlefy")
  end

  def import_from_csv_url(
        csv_url,
        tournament_id,
        tournament_source \\ "imported",
        name_transformer \\ & &1,
        drop_columns \\ 0
      ) do
    %{body: body} = HTTPoison.get!(csv_url, [], follow_redirect: true)

    body
    |> parse_body()
    |> import(tournament_id, tournament_source, name_transformer, drop_columns)
  end

  def parse_body(body) do
    {:ok, io} = StringIO.open(body)

    io
    |> IO.binstream(:line)
    |> CSV.decode()
    |> Enum.flat_map(fn
      {:ok, val} -> [val]
      _ -> []
    end)
  end

  def import(
        data,
        tournament_id,
        tournament_source \\ "imported",
        name_transformer \\ & &1,
        drop_columns \\ 0
      ) do
    data
    |> Enum.reverse()
    |> Enum.uniq_by(&hd/1)
    |> Enum.reduce(Multi.new(), fn line, multi ->
      case line |> Enum.drop(drop_columns) |> parse_line() do
        {_, []} ->
          multi

        {name_raw, deckstrings} ->
          name = name_transformer.(name_raw)

          changeset =
            Hearthstone.create_lineup(
              %{name: name, tournament_id: tournament_id, tournament_source: tournament_source},
              deckstrings
            )

          Multi.insert(multi, name, changeset)
      end
    end)
    |> Repo.transaction()
  end

  def parse_line([name | deck_columns]),
    do: {name, Enum.flat_map(deck_columns, &DeckcodeExtractor.extract_decks/1)}

  def import_max_2022_nations(csv_url, round) do
    import_from_csv_url(
      csv_url,
      round,
      Backend.MaxNations2022.lineup_tournament_source(),
      &"{#{Backend.MaxNations2022.get_nation(&1)}} #{&1}"
    )
  end

  def import_mt_pubhtml(url, mt_name, tournament_source \\ "masters_tour") do
    {:ok, %{body: body}} = get(url)
    sheet_ids = mt_pubhtml_sheet_ids(body)
    spreadsheet_id = spreadsheet_id(url)

    extract_lineups_from_mt_sheets(spreadsheet_id, sheet_ids)
    |> import(mt_name, tournament_source)
  end

  def mt_pubhtml_sheet_ids(body) do
    body
    |> Floki.find("#sheet-menu")
    |> Floki.find("li")
    |> Floki.attribute("id")
    |> Enum.map(fn "sheet-button-" <> sheet_id -> sheet_id end)
  end

  def extract_lineups_from_mt_sheets(spreadsheet_id, sheet_ids) do
    Enum.flat_map(sheet_ids, fn sheet_id ->
      IO.inspect({spreadsheet_id, sheet_id}, label: :extracting_from)
      {:ok, %{body: body}} = get_sheet_csv(spreadsheet_id, sheet_id)
      extract_from_sheet_body(body)
    end)
  end

  def extract_from_sheet_body(body) do
    body
    |> String.split("\n")
    |> CSV.decode!()
    |> Enum.chunk_every(3)
    |> Enum.map(fn [[raw_name | _], _, mostly_decks] ->
      name = String.trim(raw_name)

      decks =
        for raw <- Enum.drop(mostly_decks, 1),
            fixed = String.replace(raw, ["\r\r\n", "\r\n"], "\n"),
            extracted = Regex.run(Deck.deckcode_regex("m"), fixed) do
          Enum.at(extracted, 0)
        end

      mostly_decks |> Enum.drop(1) |> Enum.at(0)
      [name | decks]
    end)
  end

  def spreadsheet_id(url) do
    for("2PACX-" <> spreadsheet_id <- String.split(url, "/"), do: spreadsheet_id)
    |> Enum.at(0)
  end

  def get_sheet_csv(spreadsheet_id, sheet_id) do
    get(
      "https://docs.google.com/spreadsheets/d/e/2PACX-#{spreadsheet_id}/pub?output=csv&gid=#{sheet_id}"
    )
  end
end
