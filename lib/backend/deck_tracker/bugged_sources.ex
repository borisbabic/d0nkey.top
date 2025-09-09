defmodule Hearthstone.DeckTracker.BuggedSources do
  @moduledoc "Sources that should be excluded from data because the deck tracker was bugged"
  use Ecto.Schema
  import Ecto.Changeset
  alias Hearthstone.DeckTracker.Source

  schema "dt_bugged_sources" do
    field :filter_out, :boolean, default: true
    belongs_to :source, Source
    timestamps()
  end

  def changeset(bs, attrs) do
    bs
    |> cast(attrs, [:source_id, :filter_out])
  end
end
