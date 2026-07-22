defmodule Backend.Api do
  @moduledoc """
  The Api context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Ecto.Multi
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.Api.ApiUser
  alias Backend.Api.DeveloperApiKey
  alias Backend.UserManager.User

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of api_users using filtrex
  filters.

  ## Examples

  iex> list_api_users(%{})
  %{api_users: [%ApiUser{}], ...}
  """
  @spec paginate_api_users(map) :: {:ok, map} | {:error, any}
  def paginate_api_users(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:api_users), params["api_user"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_api_users(filter, params) do
      {:ok,
       %{
         api_users: page.entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_api_users(filter, params) do
    from(au in ApiUser)
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
    Returns the list of api_users.

  ## Examples

  iex> list_api_users()
  [%ApiUser{}, ...]

  """
  def list_api_users do
    Repo.all(ApiUser)
  end

  @doc """
  Gets a single api_user.

  Raises `Ecto.NoResultsError` if the Api user does not exist.

  ## Examples

  iex> get_api_user!(123)
  %ApiUser{}

  iex> get_api_user!(456)
  ** (Ecto.NoResultsError)

  """
  def get_api_user!(id), do: Repo.get!(ApiUser, id)

  @doc """
  Creates a api_user.

  ## Examples

  iex> create_api_user(%{field: value})
  {:ok, %ApiUser{}}

  iex> create_api_user(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_api_user(attrs \\ %{}) do
    %ApiUser{}
    |> ApiUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a api_user.

  ## Examples

  iex> update_api_user(api_user, %{field: new_value})
  {:ok, %ApiUser{}}

  iex> update_api_user(api_user, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_api_user(%ApiUser{} = api_user, attrs) do
    api_user
    |> ApiUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ApiUser.

  ## Examples

  iex> delete_api_user(api_user)
  {:ok, %ApiUser{}}

  iex> delete_api_user(api_user)
  {:error, %Ecto.Changeset{}}

  """
  def delete_api_user(%ApiUser{} = api_user) do
    Repo.delete(api_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking api_user changes.

  ## Examples

  iex> change_api_user(api_user)
  %Ecto.Changeset{source: %ApiUser{}}

  """
  def change_api_user(%ApiUser{} = api_user, attrs \\ %{}) do
    ApiUser.changeset(api_user, attrs)
  end

  defp filter_config(:api_users) do
    defconfig do
      text(:username)
      text(:password)
    end
  end

  @spec verify_user(String.t(), String.t()) :: {:ok, ApiUser.t()} | {:error, reason :: atom()}
  def verify_user(username, password) do
    query =
      from(u in ApiUser,
        where: u.username == ^username,
        select: u
      )

    with %{id: _id} = user <- Repo.one(query),
         true <- ApiUser.verify_password?(user, password) do
      {:ok, user}
    else
      nil -> {:error, :user_not_found}
      false -> {:error, :incorrect_password}
      _ -> {:error, :unknown_error}
    end
  end

  @doc """
  Creates a new developer API key and revokes the user's previous key.

  The plaintext token is returned once and is never persisted.
  """
  @spec create_developer_api_key(User.t()) ::
          {:ok, %{api_key: DeveloperApiKey.t(), token: String.t()}} | {:error, term()}
  def create_developer_api_key(%User{id: user_id}) do
    token_prefix = "hsg_live_" <> random_token(9)
    secret = random_token(32)
    token = token_prefix <> "." <> secret
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    attrs = %{
      user_id: user_id,
      token_prefix: token_prefix,
      token_digest: token_digest(secret)
    }

    Multi.new()
    |> Multi.run(:user, fn repo, _changes ->
      case repo.one(from u in User, where: u.id == ^user_id, lock: "FOR UPDATE") do
        %User{} = user -> {:ok, user}
        nil -> {:error, :user_not_found}
      end
    end)
    |> Multi.update_all(
      :revoked_keys,
      active_developer_api_keys_query(user_id),
      set: [revoked_at: now, updated_at: now]
    )
    |> Multi.insert(:api_key, DeveloperApiKey.changeset(%DeveloperApiKey{}, attrs))
    |> Repo.transaction()
    |> case do
      {:ok, %{api_key: api_key}} -> {:ok, %{api_key: api_key, token: token}}
      {:error, _operation, reason, _changes} -> {:error, reason}
    end
  end

  @doc "Returns the user's active developer API key, if one exists."
  @spec get_active_developer_api_key(User.t()) :: DeveloperApiKey.t() | nil
  def get_active_developer_api_key(%User{id: user_id}) do
    user_id
    |> active_developer_api_keys_query()
    |> Repo.one()
  end

  @doc "Revokes the developer API key owned by the given user."
  @spec revoke_developer_api_key(User.t()) :: :ok | {:error, term()}
  def revoke_developer_api_key(%User{id: user_id}) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Multi.new()
    |> Multi.run(:user, fn repo, _changes ->
      case repo.one(from u in User, where: u.id == ^user_id, lock: "FOR UPDATE") do
        %User{} = user -> {:ok, user}
        nil -> {:error, :user_not_found}
      end
    end)
    |> Multi.update_all(
      :revoked_keys,
      active_developer_api_keys_query(user_id),
      set: [revoked_at: now, updated_at: now]
    )
    |> Repo.transaction()
    |> case do
      {:ok, _changes} -> :ok
      {:error, _operation, reason, _changes} -> {:error, reason}
    end
  end

  @doc "Verifies an active developer API key and loads its owner."
  @spec verify_developer_api_key(String.t()) ::
          {:ok, DeveloperApiKey.t()} | {:error, :invalid_api_key}
  def verify_developer_api_key(token) when is_binary(token) do
    with {:ok, token_prefix, secret} <- parse_developer_api_key(token),
         %DeveloperApiKey{} = api_key <- developer_api_key_by_prefix(token_prefix),
         true <- Plug.Crypto.secure_compare(api_key.token_digest, token_digest(secret)) do
      {:ok, api_key}
    else
      _ -> {:error, :invalid_api_key}
    end
  end

  def verify_developer_api_key(_), do: {:error, :invalid_api_key}

  defp active_developer_api_keys_query(user_id) do
    from key in DeveloperApiKey,
      where: key.user_id == ^user_id and is_nil(key.revoked_at)
  end

  defp developer_api_key_by_prefix(token_prefix) do
    from(key in DeveloperApiKey,
      join: user in assoc(key, :user),
      where: key.token_prefix == ^token_prefix and is_nil(key.revoked_at),
      preload: [user: user]
    )
    |> Repo.one()
  end

  defp parse_developer_api_key("hsg_live_" <> _ = token) do
    case String.split(token, ".", parts: 2) do
      [token_prefix, secret] when secret != "" -> {:ok, token_prefix, secret}
      _ -> {:error, :invalid_api_key}
    end
  end

  defp parse_developer_api_key(_), do: {:error, :invalid_api_key}

  defp random_token(bytes),
    do: bytes |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

  defp token_digest(secret), do: :crypto.hash(:sha256, secret)
end
