defmodule Backend.Streaming.DeckStreamingInfo do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :peak, integer | nil
    field :peaked_by, String.t() | nil
    field :streamers, [String.t()]
    field :first_streamed_by, String.t() | nil
  end

  def empty(),
    do: %__MODULE__{
      peak: nil,
      peaked_by: nil,
      streamers: [],
      first_streamed_by: nil
    }
end
