defmodule Backend.UserManager.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.UserManager.User.DecklistOptions
  alias Backend.Patreon.PatreonTier

  schema "users" do
    field :battletag, :string
    field :bnet_id, :integer
    field :battlefy_slug, :string
    field :country_code, :string
    field :admin_roles, {:array, :string}, default: []
    field :hide_ads, :boolean
    field :unicode_icon, :string
    field :twitch_id, :string
    field :patreon_id, :string
    field :cross_out_country, :boolean, default: false
    field :show_region, :boolean, default: false

    field :replay_preference, Ecto.Enum,
      values: [all: 0, streamed: 8, none: 16],
      default: :streamed

    embeds_one(:decklist_options, DecklistOptions, on_replace: :delete)
    belongs_to :patreon_tier, PatreonTier, type: :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs = %{admin_roles: ar = [r | _]}) when is_atom(r) do
    new_attrs = attrs |> Map.put(:admin_roles, ar |> Enum.map(&to_string/1))
    changeset(user, new_attrs)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :battletag,
      :bnet_id,
      :battlefy_slug,
      :country_code,
      :admin_roles,
      :hide_ads,
      :twitch_id,
      :patreon_id,
      :patreon_tier_id,
      :cross_out_country,
      :show_region,
      :replay_preference,
      :unicode_icon
    ])
    |> cast_embed(:decklist_options)
    |> validate_required([:battletag, :bnet_id])
    |> validate_length(:country_code, min: 2, max: 2)
    |> capitalize_country_code()
    |> unique_constraint(:twitch_id)
    |> unique_constraint(:patreon_id)
    |> unique_constraint(:bnet_id)
  end

  @spec capitalize_country_code(Ecto.Changset.t()) :: Ecto.Changeset.t()
  def capitalize_country_code(cs) do
    cs
    |> fetch_change(:country_code)
    |> case do
      {:ok, cc} when is_binary(cs) -> cs |> put_change(:country_code, String.upcase(cc))
      _ -> cs
    end
  end

  def battletag!(%{battletag: btag}), do: btag
  def battletag(%{battletag: btag}), do: btag
  def battletag(_), do: nil

  def display_name(%__MODULE__{battletag: bt}),
    do: bt |> Backend.MastersTour.InvitedPlayer.shorten_battletag()

  @spec all_admin_roles() :: [atom()]
  def all_admin_roles(),
    do: [
      :super,
      :battletag_info,
      :users,
      :invites,
      :feed_items,
      :fantasy_leagues,
      :api_users,
      :old_battletags,
      :groups,
      :deck,
      :period,
      :format,
      :rank,
      :archetyping,
      :tournament_streams,
      :twitch_commands
    ]

  @spec string_admin_roles() :: [String.t()]
  def string_admin_roles(), do: all_admin_roles() |> Enum.map(&to_string/1)

  @spec can_access?(User.t(), String.t()) :: boolean
  def can_access?(%{admin_roles: ar}, r) when is_list(ar),
    do: ar |> Enum.map(&to_string/1) |> Enum.any?(&(&1 in [r |> to_string(), "super"]))

  def can_access?(_, _), do: false

  def super_admin?(%{admin_roles: ar}) do
    is_list(ar) && ("super" in ar || :super in ar)
  end

  @spec is_role?(atom() | String.t()) :: boolean()
  def is_role?(atom_or_string), do: (atom_or_string |> to_string()) in string_admin_roles()

  def hide_ads?(%{hide_ads: true}), do: true
  def hide_ads?(%{patreon_tier: %{ad_free: true}}), do: true
  def hide_ads?(%{admin_roles: ar}) when is_list(ar), do: !(ar |> Enum.empty?())
  def hide_ads?(_), do: false

  def decklist_options(%{decklist_options: deck_opts}) when is_map(deck_opts), do: deck_opts
  def decklist_options(_), do: %{}

  def replay_public?(%{replay_preference: :all}, _stream_live), do: true
  def replay_public?(%{replay_preference: :streamed}, stream_live), do: stream_live
  def replay_public?(%{replay_preference: :none}, _stream_live), do: false
  def replay_public?(_, _), do: false

  @spec streamer?(User.t() | nil) :: boolean()
  def streamer?(%{twitch_id: twitch}) when is_binary(twitch), do: true
  def streamer?(_), do: false

  @spec stream_tuples(User.t() | nil) :: [{String.t(), String.t()}]
  def stream_tuples(%{twitch_id: twitch_id}) when is_binary(twitch_id) do
    [{"twitch", twitch_id}]
  end

  def stream_tuples(_), do: []
end

defmodule Backend.UserManager.User.DecklistOptions do
  @moduledoc "User options for how decklists are displayed"
  use Ecto.Schema
  import Ecto.Changeset

  @default_show_one false
  @default_show_one_for_legendaries false
  @default_show_dust_above false
  @default_show_dust_below true
  @primary_key false
  embedded_schema do
    field :border, :string
    field :show_one, :boolean, default: @default_show_one
    field :show_one_for_legendaries, :boolean, default: @default_show_one_for_legendaries
    field :gradient, :string
    field :show_dust_above, :boolean, default: @default_show_dust_above
    field :show_dust_below, :boolean, default: @default_show_dust_below
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :border,
      :gradient,
      :show_one,
      :show_one_for_legendaries,
      :show_dust_above,
      :show_dust_below
    ])
    |> validate_colors([:border, :gradient])
  end

  def show_one(%{show_one: show_one}), do: show_one
  def show_one(_), do: @default_show_one

  def show_one_for_legendaries(%{show_one_for_legendaries: show_one}), do: show_one
  def show_one_for_legendaries(_), do: @default_show_one_for_legendaries

  def default_show_dust_above(), do: @default_show_dust_above
  def show_dust_above(%{show_dust_above: show}), do: show
  def show_dust_above(_), do: @default_show_dust_above

  def default_show_dust_below(), do: @default_show_dust_below
  def show_dust_below(%{show_dust_below: show}), do: show
  def show_dust_below(_), do: @default_show_dust_below

  def border(%{border: b}), do: b
  def border(_), do: "dark_grey"

  def gradient(%{gradient: g}), do: g
  def gradient(_), do: "rarity"

  def valid_color?(opt),
    do: opt in ["dark_grey", "card_class", "deck_class", "rarity", "deck_format"]

  def show_one_for_legendaries_default(), do: @default_show_one_for_legendaries
  def show_one_default(), do: @default_show_one

  def validate_colors(changeset, fields) do
    Enum.reduce(fields, changeset, fn f, cs ->
      validate_change(cs, f, &color_validator/2)
    end)
  end

  defp color_validator(field, value) do
    if valid_color?(value) do
      []
    else
      [{field, "Invalid color for decklist options"}]
    end
  end
end
