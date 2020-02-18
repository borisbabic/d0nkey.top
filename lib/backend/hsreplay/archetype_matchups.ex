defmodule Backend.HSReplay.ArchetypeMatchups do
  use TypedStruct

  @type archetype_matchups_data ::
          %{
            HSReplay.atchetype_id() => %{
              HSReplay.atchetype_id() => Backend.HSReplay.MatchupEntry
            }
          }
  typedstruct enforce: true do
    field :data, archetype_matchups_data
    field :updated_at, NaiveDateTime.t()
  end

  def from_raw_map(%{
        "as_of" => as_of,
        "series" => %{
          "data" => data_raw
        }
      }) do
    data =
      for {outer_key, outer_value} <- data_raw, into: %{} do
        {
          Util.to_int_or_orig(outer_key),
          for {inner_key, inner_value} <- outer_value do
            {
              Util.to_int_or_orig(inner_key),
              Backend.HSReplay.MatchupEntry.from_raw_map(inner_value)
            }
          end
        }
      end

    %__MODULE__{
      updated_at: NaiveDateTime.from_iso8601!(as_of),
      data: data
    }
  end

  def get_matchup(%__MODULE__{} = matchups, %{id: as_id}, %{id: vs_id}) do
    get_matchup(matchups, as_id, vs_id)
  end

  def get_matchup(%__MODULE__{} = matchups, as, vs) do
    matchups.data
    |> Map.get(as)
    |> List.keyfind(vs, 0)
    |> elem(1)
  end
end
