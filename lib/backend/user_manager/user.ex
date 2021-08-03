defmodule Backend.UserManager.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.UserManager.User.DecklistOptions

  schema "users" do
    field :battletag, :string
    field :bnet_id, :integer
    field :battlefy_slug, :string
    field :country_code, :string
    field :admin_roles, {:array, :string}, default: []
    field :hide_ads, :boolean
    field :unicode_icon, :string
    field :twitch_id, :string
    embeds_one(:decklist_options, DecklistOptions, on_replace: :delete)

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
      :unicode_icon
    ])
    |> cast_embed(:decklist_options)
    |> validate_required([:battletag, :bnet_id])
    |> validate_length(:country_code, min: 2, max: 2)
    |> capitalize_country_code()
    |> unique_constraint(:twitch_id)
    |> unique_constraint(:bnet_id)
  end

  @spec capitalize_country_code(Ecto.Changset.t()) :: Ecto.Changeset.t()
  def capitalize_country_code(cs) do
    cs
    |> fetch_change(:country_code)
    |> case do
      {:ok, cc} -> cs |> put_change(:country_code, String.upcase(cc))
      _ -> cs
    end
  end

  def display_name(%__MODULE__{battletag: bt}),
    do: bt |> Backend.MastersTour.InvitedPlayer.shorten_battletag()

  @spec all_admin_roles() :: [atom()]
  def all_admin_roles(),
    do: [:super, :battletag_info, :users, :invites, :feed_items, :fantasy_leagues, :api_users]

  @spec string_admin_roles() :: [String.t()]
  def string_admin_roles(), do: all_admin_roles() |> Enum.map(&to_string/1)

  @spec can_access?(User.t(), String.t()) :: boolean
  def can_access?(%{admin_roles: ar}, r) when is_list(ar),
    do: ar |> Enum.map(&to_string/1) |> Enum.any?(&(&1 in [r |> to_string(), "super"]))

  def can_access?(_, _), do: false

  @spec is_role?(atom() | String.t()) :: boolean()
  def is_role?(atom_or_string), do: (atom_or_string |> to_string()) in string_admin_roles()

  def hide_ads?(%{hide_ads: true}), do: true
  def hide_ads?(%{admin_roles: ar}) when is_list(ar), do: !(ar |> Enum.empty?())
  def hide_ads?(_), do: false

  def decklist_options(%{decklist_options: deck_opts}) when is_map(deck_opts), do: deck_opts
  def decklist_options(_), do: %{}
end

defmodule Backend.UserManager.User.DecklistOptions do
  @moduledoc "User options for how decklists are displayed"
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :border, :string
    field :gradient, :string
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:border, :gradient])
    |> validate_colors([:border, :gradient])
  end

  def border(%{border: b}), do: b
  def border(_), do: "dark_grey"

  def gradient(%{gradient: g}), do: g
  def gradient(_), do: "rarity"

  def valid?(opt), do: opt in ["dark_grey", "card_class", "deck_class", "rarity"]

  def validate_colors(changeset, fields) do
    fields
    |> Enum.reduce(changeset, fn f, cs ->
      validate_change(cs, f, fn f, value ->
        if valid?(value) do
          []
        else
          [{f, "Invalid color for decklist options"}]
        end
      end)
    end)
  end
end
