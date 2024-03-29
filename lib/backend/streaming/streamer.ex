defmodule Backend.Streaming.Streamer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @required [:twitch_id]
  schema "streamer" do
    field :hsreplay_twitch_login, :string
    field :hsreplay_twitch_display, :string
    field :twitch_login, :string
    field :twitch_display, :string
    field :twitch_id, :integer
    timestamps()
  end

  def changeset(s, attrs) do
    s
    |> cast(attrs, [
      :hsreplay_twitch_login,
      :hsreplay_twitch_display,
      :twitch_login,
      :twitch_display,
      :twitch_id
    ])
    |> validate_required(@required)
  end

  def twitch_login(s = %__MODULE__{}), do: s.twitch_login || s.hsreplay_twitch_login
  def twitch_display(s = %__MODULE__{}), do: s.twitch_display || s.hsreplay_twitch_display
end
