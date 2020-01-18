defmodule Backend.Battlefy.Tournament do
  use TypedStruct
  alias Backend.Battlefy

  typedstruct enforce: true do
    field :id, Battlefy.tournament_id()
    field :stage_ids, [Battlefy.stage_id()]
    field :start_time, Calendar.datetime()
    field :last_completed_match_at, Calendar.datetime() | nil
    field :name, Calendar.datetime()
    field :slug, String.t()
  end

  @spec from_raw_map(map) :: Backend.Battlefy.Tournament.t()
  def from_raw_map(map = %{"startTime" => _}) do
    Recase.Enumerable.convert_keys(
      map,
      &Recase.to_snake/1
    )
    |> from_raw_map
  end

  def from_raw_map(
        map = %{
          "start_time" => start_time,
          "stage_ids" => stage_ids,
          "slug" => slug,
          "name" => name
        }
      ) do
    last_completed_match_at =
      case map["last_completed_match_at"] do
        lcma when is_binary(lcma) -> NaiveDateTime.from_iso8601!(lcma)
        _ -> nil
      end

    %__MODULE__{
      id: map["id"] || map["_id"],
      stage_ids: stage_ids,
      slug: slug,
      name: name,
      start_time: NaiveDateTime.from_iso8601!(start_time),
      last_completed_match_at: last_completed_match_at
    }
  end
end
