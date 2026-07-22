defmodule Backend.Api.DeveloperApiKey do
  @moduledoc "A revocable API key owned by a Battle.net-authenticated user."

  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User

  @type t :: %__MODULE__{}

  schema "developer_api_keys" do
    field :token_prefix, :string
    field :token_digest, :binary
    field :revoked_at, :naive_datetime

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:user_id, :token_prefix, :token_digest, :revoked_at])
    |> validate_required([:user_id, :token_prefix, :token_digest])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:token_prefix)
    |> unique_constraint(:user_id, name: :developer_api_keys_one_active_per_user)
  end

  @spec active?(t()) :: boolean()
  def active?(%__MODULE__{revoked_at: nil}), do: true
  def active?(%__MODULE__{}), do: false
end
