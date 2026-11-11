defmodule Backend.Creators.CreatorProfile do
  @moduledoc """
  A content creator's public page settings.

  Every field is optional, creators may have any combination of twitch, youtube, socials and decks.
  The short `slug` (ie /creator/kripp) requires admin approval, see `Backend.Creators`
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.UserManager.User
  alias Backend.Hearthstone.Deck

  @type t() :: %__MODULE__{}

  @max_links 16
  @max_link_length 420
  @max_bio_length 280
  @reserved_slugs ~w(twitch youtube settings setup admin new edit me profile api)

  schema "creator_profiles" do
    belongs_to :user, User
    field :enabled, :boolean, default: false
    field :bio, :string
    field :links, {:array, :string}, default: []
    field :show_stream, :boolean, default: true
    field :show_player_profile, :boolean, default: false
    field :deck_source, Ecto.Enum, values: [:streamer, :public, :none], default: :streamer
    belongs_to :pinned_deck, Deck
    field :show_recent_decks, :boolean, default: true
    field :video_mode, Ecto.Enum, values: [:latest, :pinned, :none], default: :latest
    field :pinned_video_id, :string
    field :youtube_channel_id, :string

    field :slug, :string

    field :slug_status, Ecto.Enum,
      values: [:pending, :preapproved, :approved, :rejected],
      default: nil

    field :slug_requested_at, :utc_datetime

    timestamps()
  end

  @settings_fields [
    :enabled,
    :bio,
    :links,
    :show_stream,
    :show_player_profile,
    :deck_source,
    :show_recent_decks,
    :video_mode,
    :youtube_channel_id
  ]

  @doc "Changes the creator can make freely. Pins and slugs need verification so they're set separately"
  def settings_changeset(profile, attrs) do
    profile
    |> cast(attrs, @settings_fields)
    |> update_change(:bio, &String.trim/1)
    |> validate_length(:bio, max: @max_bio_length)
    |> update_change(:links, &clean_links/1)
    |> validate_length(:links, max: @max_links)
    |> validate_change(:links, &validate_links/2)
  end

  @doc "Pinned deck/video, only call after verifying the pin belongs to/is allowed for the creator"
  def pin_changeset(profile, attrs) do
    profile
    |> change(attrs)
  end

  @doc "Requests a short slug with the given status, the status is determined by `Backend.Creators`"
  def slug_changeset(profile, slug, status) do
    profile
    |> change(slug: normalize_slug(slug), slug_status: status)
    |> put_change(:slug_requested_at, DateTime.utc_now() |> DateTime.truncate(:second))
    |> validate_required([:slug])
    |> validate_slug()
  end

  def slug_status_changeset(profile, status), do: change(profile, slug_status: status)

  def clear_slug_changeset(profile),
    do: change(profile, slug: nil, slug_status: nil, slug_requested_at: nil)

  defp validate_slug(cs) do
    cs
    |> validate_length(:slug, min: 3, max: 30)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9_-]*$/, message: "only letters, numbers, - and _ are allowed")
    |> validate_exclusion(:slug, @reserved_slugs, message: "is reserved")
    |> unique_constraint(:slug,
      name: :creator_profiles_active_slug_index,
      message: "is already taken"
    )
  end

  @spec normalize_slug(String.t() | nil) :: String.t() | nil
  def normalize_slug(nil), do: nil

  def normalize_slug(slug) when is_binary(slug) do
    slug |> String.trim() |> String.trim_leading("@") |> String.downcase()
  end

  @doc "If the short slug is live, preapproved slugs are live until an admin rejects them"
  @spec active_slug(t() | nil) :: String.t() | nil
  def active_slug(%{slug: <<slug::binary>>, slug_status: status})
      when status in [:approved, :preapproved],
      do: slug

  def active_slug(_), do: nil

  def reserved_slugs, do: @reserved_slugs
  def max_bio_length, do: @max_bio_length
  def max_links, do: @max_links

  defp clean_links(links) when is_list(links) do
    links
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&ensure_scheme/1)
    |> Enum.uniq()
  end

  defp clean_links(links), do: links

  defp ensure_scheme("http://" <> _ = link), do: link
  defp ensure_scheme("https://" <> _ = link), do: link
  defp ensure_scheme(link), do: "https://" <> link

  defp validate_links(:links, links) do
    links
    |> Enum.reject(&valid_link?/1)
    |> Enum.map(&{:links, "invalid link: #{String.slice(&1, 0, 50)}"})
  end

  @doc false
  def valid_link?(link) when byte_size(link) > @max_link_length, do: false

  def valid_link?(link) do
    case URI.parse(link) do
      %URI{scheme: scheme, host: <<host::binary>>} when scheme in ["http", "https"] ->
        String.contains?(host, ".")

      _ ->
        false
    end
  end
end
