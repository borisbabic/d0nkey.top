defmodule Backend.TournamentStreams.TournamentStream do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournament_streams" do
    field :stream_id, :string
    field :streaming_platform, :string
    field :tournament_id, :string
    field :tournament_source, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(tournament_stream, attrs) do
    tournament_stream
    |> cast(attrs, [:tournament_source, :tournament_id, :streaming_platform, :stream_id, :user_id])
    |> validate_required([:tournament_source, :tournament_id, :streaming_platform, :stream_id])
  end

  def stream_tuple(%{streaming_platform: platform, stream_id: id}), do: {platform, id}
  def tournament_tuple(%{streaming_platform: platform, stream_id: id}), do: {platform, id}
end
