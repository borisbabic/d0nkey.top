defmodule HSBGClub.Api do
  @moduledoc "Scrapes the tournaments page of hsbgclub.com since it doesn't have an api"
  alias HSBGClub.Tournament

  @tournaments_url "https://hsbgclub.com/Tournaments"

  @spec tournaments() :: {:ok, [Tournament.t()]} | {:error, any()}
  def tournaments do
    with {:ok, %{status: 200, body: body}} <- Req.get(@tournaments_url),
         {:ok, document} <- Floki.parse_document(body) do
      {:ok, parse_tournaments(document)}
    else
      {:error, _reason} = r -> r
      _ -> {:error, :unknown_error_getting_hsbg_club_tournaments}
    end
  end

  @spec parse_tournaments(Floki.html_tree()) :: [Tournament.t()]
  def parse_tournaments(document) do
    for row <- Floki.find(document, "table.ledger > tr, table.ledger > tbody > tr"),
        {:ok, tournament} <- [row |> row_cells() |> Tournament.from_cells()],
        uniq: true,
        do: tournament
  end

  defp row_cells(row) do
    for {"td", _, _} = cell <- Floki.children(row, include_text: false),
        do: cell |> Floki.text() |> String.trim()
  end
end
