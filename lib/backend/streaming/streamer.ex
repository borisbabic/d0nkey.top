defmodule Backend.Streaming.Streamer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @required [:twitch_login, :twitch_display, :twitch_id]
  schema "streamer" do
    field :twitch_login, :string
    field :twitch_display, :string
    field :twitch_id, :integer
    timestamps()
  end

  def changeset(s, attrs) do
    s
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end
