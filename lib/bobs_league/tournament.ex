defmodule BobsLeague.Api.Tournament do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field(:id, String.t())
    field(:name, String.t())
    field(:date, NaiveDateTime.t())
    field(:server, String.t())
    field(:type, String.t() | nil)
    field(:state, String.t() | nil)
  end

  def link(%{id: id}) do
    "https://www.bobsleague.com/events/#{id}/tournament"
  end

  @spec server(t()) :: atom()
  def server(%{server: server}) do
    case Backend.Blizzard.get_region_identifier(server) do
      {:ok, region} -> region
      _ -> server
    end
  end

  def tags(tour) do
    [server(tour), :battlegrounds]
  end

  @spec from_raw_map(Map.t()) :: {:ok, t()} | {:error, any()}
  def from_raw_map(map) do
    with id when not is_nil(id) <- Map.get(map, "_id"),
         name when not is_nil(name) <- Map.get(map, "name"),
         date_raw when not is_nil(date_raw) <- Map.get(map, "date"),
         {:ok, date} <- Timex.parse(date_raw, "{RFC3339z}"),
         server when not is_nil(server) <- Map.get(map, "server") do
      tour = %__MODULE__{
        id: id,
        name: name,
        date: date,
        server: server,
        type: map["type"],
        state: map["state"]
      }

      {:ok, tour}
    else
      r = {:error, _reason} -> r
      _ -> {:error, :unknown_error_parsing_bobs_league_tournaments}
    end
  end
end
