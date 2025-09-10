defmodule GeekLounge.Hearthstone.Tournament do
  @moduledoc false
  use TypedStruct

  alias GeekLounge.Hearthstone.Round
  alias GeekLounge.Hearthstone.Participant

  typedstruct do
    field :id, String.t()
    field :name, String.t()
    field :created_at, NaiveDateTime.t()
    field :rounds, [Round.t()]
    field :participants, [Participant.t()]
  end

  def from_raw_map(map) do
    created_at =
      case NaiveDateTime.from_iso8601(map["createdAt"]) do
        {:ok, created_at} -> created_at
        _ -> nil
      end

    %__MODULE__{
      id: map["id"],
      name: map["name"],
      created_at: created_at,
      rounds: map["rounds"] |> Enum.map(&Round.from_raw_map/1),
      participants: map["participants"] |> Enum.map(&Participant.from_raw_map/1)
    }
  end
end
