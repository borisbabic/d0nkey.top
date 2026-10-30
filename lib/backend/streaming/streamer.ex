defmodule Backend.Streaming.Streamer do
  @moduledoc "A streamer's channel, either on twitch or on youtube"
  use Ecto.Schema
  import Ecto.Changeset
  @type t() :: %__MODULE__{}
  schema "streamer" do
    field :hsreplay_twitch_login, :string
    field :hsreplay_twitch_display, :string
    field :twitch_login, :string
    field :twitch_display, :string
    field :twitch_id, :integer
    field :youtube_channel_id, :string
    field :youtube_display, :string
    field :youtube_handle, :string
    timestamps()
  end

  def changeset(s, attrs) do
    s
    |> cast(attrs, [
      :hsreplay_twitch_login,
      :hsreplay_twitch_display,
      :twitch_login,
      :twitch_display,
      :twitch_id,
      :youtube_channel_id,
      :youtube_display,
      :youtube_handle
    ])
    |> validate_channel()
    |> unique_constraint(:youtube_channel_id)
    |> check_constraint(:twitch_id, name: :streamer_has_channel)
  end

  defp validate_channel(cs) do
    if get_field(cs, :twitch_id) || get_field(cs, :youtube_channel_id) do
      cs
    else
      add_error(cs, :twitch_id, "twitch_id or youtube_channel_id is required")
    end
  end

  def twitch_login(%__MODULE__{} = s), do: s.twitch_login || s.hsreplay_twitch_login
  def twitch_display(%__MODULE__{} = s), do: s.twitch_display || s.hsreplay_twitch_display

  @spec platform(t()) :: :twitch | :youtube
  def platform(%{twitch_id: nil, youtube_channel_id: <<_::binary>>}), do: :youtube
  def platform(_), do: :twitch

  @doc "Display name regardless of platform"
  @spec display_name(t()) :: String.t() | nil
  def display_name(%__MODULE__{} = s) do
    case platform(s) do
      :youtube -> s.youtube_display || s.youtube_handle || s.youtube_channel_id
      :twitch -> twitch_display(s)
    end
  end

  @doc "Secondary identifier (login or handle), regardless of platform"
  @spec login(t()) :: String.t() | nil
  def login(%__MODULE__{} = s) do
    case platform(s) do
      :youtube -> s.youtube_handle
      :twitch -> twitch_login(s)
    end
  end

  @spec youtube_link(t()) :: String.t() | nil
  def youtube_link(%{youtube_handle: "@" <> _ = handle}), do: "https://www.youtube.com/#{handle}"

  def youtube_link(%{youtube_channel_id: <<id::binary>>}),
    do: "https://www.youtube.com/channel/#{id}"

  def youtube_link(_), do: nil

  @doc "Query param used to filter streamer decks by this streamer"
  @spec filter_param(t()) :: {String.t(), String.t()}
  def filter_param(%__MODULE__{} = s) do
    case platform(s) do
      :youtube -> {"youtube_channel_id", s.youtube_channel_id}
      :twitch -> {"twitch_id", to_string(s.twitch_id)}
    end
  end

  def filter_params, do: ["twitch_id", "twitch_login", "youtube_channel_id"]
end
