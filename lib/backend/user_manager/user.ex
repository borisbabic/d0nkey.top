defmodule Backend.UserManager.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :battletag, :string
    field :bnet_id, :integer
    field :battlefy_slug, :string
    field :country_code, :string
    field :admin_roles, {:array, :string}, default: []

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:battletag, :bnet_id, :battlefy_slug, :country_code, :admin_roles])
    |> validate_required([:battletag, :bnet_id])
    |> validate_length(:country_code, min: 2, max: 2)
    |> capitalize_country_code()
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

  def all_admin_roles(), do: [:super, :battletag_info, :users, :invites, :feed_items]
  def string_admin_roles(), do: all_admin_roles() |> Enum.map(&to_string/1)

  @spec can_access?(User.t(), String.t()) :: boolean
  def can_access?(%{admin_roles: ar}, r) when is_list(ar),
    do: ar |> Enum.map(&to_string/1) |> Enum.any?(&(&1 in [r |> to_string(), "super"]))

  def can_access?(_, _), do: false

  @spec is_role?(atom() | String.t()) :: boolean()
  def is_role?(atom_or_string), do: (atom_or_string |> to_string()) in string_admin_roles()
end
