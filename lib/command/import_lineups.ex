defmodule Command.ImportLineups do
  import Ecto.Query, warn: false
  alias BackendWeb.DeckviewerLive
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Hearthstone
  def import_from_csv_url(csv_url, tournament_id, tournament_source \\ "imported", name_transformer \\ & &1) do
    %{body: body} = HTTPoison.get!(csv_url, [], follow_redirect: true)
    body
    |> parse_body()
    |> import(tournament_id, tournament_source, name_transformer)
  end

  def parse_body(body) do
    body
    |> String.split(["\n", "\r\n"])
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.trim/1)
    end)
  end

  def import(data, tournament_id, tournament_source \\ "imported", name_transformer \\ & &1) do
    data
    |> Enum.reduce(Multi.new(), fn line, multi ->
      {name_raw, deckstrings} = parse_line(line)
      name = name_transformer.(name_raw)
      changeset = Hearthstone.create_lineup(%{name: name, tournament_id: tournament_id, tournament_source: tournament_source}, deckstrings)
      Multi.insert(multi, name, changeset)
    end)
    |> Repo.transaction()
  end

  def parse_line([name | deck_columns]), do: {name, Enum.flat_map(deck_columns, &DeckviewerLive.extract_decks/1)}

  def import_max_2022_nations(csv_url, round) do
    import_from_csv_url(csv_url, round, Backend.MaxNations2022.lineup_tournament_source(), & "{#{Backend.MaxNations2022.get_nation(&1)}} #{&1}")
  end
end
