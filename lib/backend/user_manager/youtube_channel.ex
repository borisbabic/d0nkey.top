defmodule Backend.UserManager.YoutubeChannel do
  @moduledoc "A youtube channel connected to a user via oauth"
  @type t() :: %__MODULE__{}
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.UserManager.User

  schema "youtube_channels" do
    field :channel_id, :string
    field :title, :string
    field :handle, :string
    field :thumbnail_url, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:channel_id, :title, :handle, :thumbnail_url])
    |> validate_required([:channel_id])
    |> unique_constraint(:channel_id)
  end

  def url(%{handle: "@" <> _ = handle}), do: "https://www.youtube.com/#{handle}"
  def url(%{channel_id: channel_id}), do: "https://www.youtube.com/channel/#{channel_id}"
end
