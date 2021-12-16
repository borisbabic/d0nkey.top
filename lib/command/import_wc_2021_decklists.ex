defmodule Command.ImportWC2021 do
  alias Backend.Grandmasters.Response.Tournament
  alias Backend.Grandmasters.LineupFetcher
  def import() do
    with {:ok, raw} <- File.read("lib/data/wc_data_2021.json"),
         {:ok, decoded} <- Jason.decode(raw),
         tournament <- Tournament.from_raw_map(decoded),
         decklists <- Tournament.decklists(tournament) do
      LineupFetcher.save_decklists(decklists, "wc_2021", "import_command")
    end
  end
end
