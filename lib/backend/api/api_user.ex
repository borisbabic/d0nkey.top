defmodule Backend.Api.ApiUser do
  @moduledoc """
  Users for api basic auth
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_users" do
    field :password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(api_user, attrs) do
    api_user
    |> cast(attrs, [:username, :password])
    |> put_pass_hash()
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
  end

  defp put_pass_hash(cs = %Ecto.Changeset{valid?: true, changes: %{password: password}})
       when not is_nil(password) do
    change(cs, Bcrypt.hash_pwd_salt(password, hash_key: :password))
  end

  defp put_pass_hash(cs), do: cs

  def verify_password?(%{password: hashed}, pass), do: Bcrypt.verify_pass(pass, hashed)
end
