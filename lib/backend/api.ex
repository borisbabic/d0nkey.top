defmodule Backend.Api do
  @moduledoc """
  The Api context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.Api.ApiUser

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

    with user = %{id: _id} <- Repo.one(query),
         true <- ApiUser.verify_password?(user, password) do
      {:ok, user}
    else
      nil -> {:error, :user_not_found}
      false -> {:error, :incorrect_password}
      _ -> {:error, :unknown_error}
    end
  end
end
