defmodule Backend.Streaming.Streamer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @required [:hsreplay_twitch_login, :hsreplay_twitch_display, :twitch_id]
  schema "streamer" do
    field :hsreplay_twitch_login, :string
    field :hsreplay_twitch_display, :string
    field :twitch_id, :integer
    timestamps()
  end

  def changeset(s, attrs) do
    s
    |> cast(attrs, @required)
    |> validate_required(@required)
  end

  def twitch_login(s = %__MODULE__{}), do: s.hsreplay_twitch_login
  def twitch_display(s = %__MODULE__{}), do: s.hsreplay_twitch_display
end
