defmodule Command.ImportLineups do
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Hearthstone.DeckcodeExtractor
  alias Backend.Hearthstone

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
end
