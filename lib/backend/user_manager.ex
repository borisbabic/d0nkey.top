defmodule Backend.UserManager do
  @moduledoc """
  The UserManager context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Ecto.Multi
  @type bnet_info :: %{battletag: String.t(), bnet_id: String.t()}
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

  alias Backend.UserManager.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
    |> update_user_info()
  end

  def update_user_info({:error, _} = ret), do: ret

  def update_user_info({:ok, user} = ret) do
    Backend.Battlenet.update_user_country(user)
    Backend.PlayerIconBag.set_user_icons(user)
    ret
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Paginate the list of users using filtrex
  filters.

  ## Examples

      iex> paginate_users(%{})
      %{users: [%User{}], ...}
  """
  @spec paginate_users(map) :: {:ok, map} | {:error, any}
  def paginate_users(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:users), params["user"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_users(filter, params) do
      {:ok,
       %{
         users: page.entries,
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

  defp do_paginate_users(filter, params) do
    User
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:users) do
    defconfig do
      text(:battletag)
      number(:bnet_id)
      text(:battlefy_slug)
      text(:country_code)
    end
  end

  @doc """
  Finds the bnet user if it exists, creates one if it doesn't.
  """
  @spec ensure_bnet_user(bnet_info()) :: User
  def ensure_bnet_user(%{bnet_id: id, battletag: info_btag} = bnet_info) do
    case Repo.get_by(User, bnet_id: id) do
      nil -> create_bnet_user!(bnet_info)
      user = %{battletag: db_btag} when db_btag != info_btag -> update_battletag(user, info_btag)
      user -> user
    end
  end

  def update_battletag(user, new_btag) do
    cs = User.changeset(user, %{battletag: new_btag})

    battletag_cs = Backend.Battlenet.battletag_change_changeset(user, new_btag)
    Multi.new()
    |> Multi.update("update_user_btag_#{user.id}", cs)
    |> Multi.insert("old_battletag_for_user#{user.id}", battletag_cs)
    |> Repo.transaction()

    get_user!(user.id)
  end

  @doc """
  Creates the bnet user
  """
  @spec create_bnet_user!(bnet_info()) :: User
  def create_bnet_user!(info), do: create_user(info) |> Util.bangify()

  @spec get_by_btag(String.t()) :: User.t() | nil
  def get_by_btag(battletag) do
    query =
      from u in User,
        select: u,
        where: u.battletag == ^battletag

    Repo.one(query)
  end

  def set_twitch(user, twitch_id) do
    user
    |> User.changeset(%{twitch_id: twitch_id})
    |> Repo.update()
  end

  def remove_twitch(user) do
    user
    |> User.changeset(%{twitch_id: nil})
    |> Repo.update()
  end
end
