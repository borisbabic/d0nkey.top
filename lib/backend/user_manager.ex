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
  alias Backend.UserManager.Group
  alias Backend.UserManager.GroupMembership

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
    Backend.PlayerCountryPreferenceBag.update_user(user)
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

  defp filter_config(:groups) do
    defconfig do
      number(:owner_id)
      text(:name)
      text(:discord)
      text(:join_code)
    end
  end

  defp filter_config(:group_memberships) do
    defconfig do
      text(:role)
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

  def set_patreon(user, patreon_id) do
    user
    |> User.changeset(%{patreon_id: patreon_id})
    |> Repo.update()
  end

  def remove_patreon(user) do
    user
    |> User.changeset(%{patreon_id: nil})
    |> Repo.update()
  end

  @doc """
  Paginate the list of groups using filtrex
  filters.

  ## Examples

      iex> list_groups(%{})
      %{groups: [%Group{}], ...}
  """
  @spec paginate_groups(map) :: {:ok, map} | {:error, any}
  def paginate_groups(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:groups), params["group"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_groups(filter, params) do
      {:ok,
       %{
         groups: page.entries,
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

  defp do_paginate_groups(filter, params) do
    Group
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id) |> Repo.preload(:owner)

  def get_group(id), do: Repo.get(Group, id) |> Repo.preload(:owner)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs = %{"owner" => owner}) do
    with {:ok, group} <- %Group{} |> Group.changeset(attrs) |> Repo.insert(),
         {:ok, group_membership} <-
           %{role: "Owner", group: group, user: owner} |> create_group_membership() do
      {:ok, group}
    end
  end

  def create_group(attrs, owner_id) do
    case get_user(owner_id) do
      nil ->
        {:error, :no_owner}

      owner ->
        attrs
        |> Map.put("owner", owner)
        |> create_group()
    end
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{source: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  @doc """
  Paginate the list of group_memberships using filtrex
  filters.

  ## Examples

      iex> list_group_memberships(%{})
      %{group_memberships: [%GroupMembership{}], ...}
  """
  @spec paginate_group_memberships(map) :: {:ok, map} | {:error, any}
  def paginate_group_memberships(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
             filter_config(:group_memberships),
             params["group_membership"] || %{}
           ),
         %Scrivener.Page{} = page <- do_paginate_group_memberships(filter, params) do
      {:ok,
       %{
         group_memberships: page.entries,
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

  defp do_paginate_group_memberships(filter, params) do
    GroupMembership
    |> Filtrex.query(filter)
    |> preload(:owner)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of group_memberships.

  ## Examples

      iex> list_group_memberships()
      [%GroupMembership{}, ...]

  """
  def list_group_memberships do
    Repo.all(GroupMembership)
  end

  @doc """
  Gets a single group_membership.

  Raises `Ecto.NoResultsError` if the Group membership does not exist.

  ## Examples

      iex> get_group_membership!(123)
      %GroupMembership{}

      iex> get_group_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_membership!(id), do: Repo.get!(GroupMembership, id)

  @doc """
  Creates a group_membership.

  ## Examples

      iex> create_group_membership(%{field: value})
      {:ok, %GroupMembership{}}

      iex> create_group_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_membership(attrs \\ %{}) do
    %GroupMembership{}
    |> GroupMembership.changeset(attrs)
    |> Repo.insert()
  end

  def create_group_membership(attrs, group_id, user_id) do
    with {:user, user = %{id: _id}} <- {:user, get_user(user_id)},
         {:group, group = %{id: _id}} <- {:group, get_group(group_id)} do
      attrs
      |> Map.put("user", user)
      |> Map.put("group", group)
      |> create_group_membership()
    else
      {:user, _} -> {:error, :could_not_get_user}
      {:group, _} -> {:error, :could_not_get_group}
    end
  end

  @doc """
  Updates a group_membership.

  ## Examples

      iex> update_group_membership(group_membership, %{field: new_value})
      {:ok, %GroupMembership{}}

      iex> update_group_membership(group_membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group_membership(%GroupMembership{} = group_membership, attrs) do
    group_membership
    |> GroupMembership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a GroupMembership.

  ## Examples

      iex> delete_group_membership(group_membership)
      {:ok, %GroupMembership{}}

      iex> delete_group_membership(group_membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_membership(%GroupMembership{} = group_membership) do
    Repo.delete(group_membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group_membership changes.

  ## Examples

      iex> change_group_membership(group_membership)
      %Ecto.Changeset{source: %GroupMembership{}}

  """
  def change_group_membership(%GroupMembership{} = group_membership, attrs \\ %{}) do
    GroupMembership.changeset(group_membership, attrs)
  end

  def user_groups(%{id: user_id}) do
    query =
      from g in Group,
        select: g,
        preload: [:owner],
        inner_join: gm in GroupMembership,
        on: g.id == gm.group_id,
        where: gm.user_id == ^user_id

    query |> Repo.all()
  end

  def user_groups(_), do: []

  @spec group_membership(Group.t(), User.t()) :: GroupMembership.t() | nil
  def group_membership(%{id: group_id}, %{id: user_id}) do
    query =
      from gm in GroupMembership,
        select: gm,
        preload: [:group, :user],
        where: gm.group_id == ^group_id,
        where: gm.user_id == ^user_id

    Repo.one(query)
  end

  def group_membership(_, _), do: nil

  def get_memberships(%Group{id: group_id}) do
    query =
      from gm in GroupMembership,
        select: gm,
        preload: [:user, :group],
        where: gm.group_id == ^group_id

    Repo.all(query)
  end

  def kick_user(user_id, group_id, admin) do
    with group = %{id: _id} <- get_group(group_id),
         user = %{id: _id} <- get_user(user_id),
         user_membership = %{id: _id} <- group_membership(group, user),
         admin_membership = %{id: _id} <- group_membership(group, admin),
         true <- GroupMembership.admin?(admin_membership) do
      delete_group_membership(user_membership)
    else
      false -> {:error, :not_an_admin}
      _ -> {:error, :could_not_kick_user}
    end
  end

  def make_admin(user_id, group_id, admin) do
    change_membership(user_id, group_id, admin, %{role: "Admin"})
  end

  def transfer_ownership(user_id, group_id, admin) do
    with group = %{id: _id} <- get_group(group_id),
         user = %{id: _id} <- get_user(user_id),
         user_membership = %{id: _id} <- group_membership(group, user),
         admin_membership = %{id: _id} <- group_membership(group, admin),
         true <- GroupMembership.owner?(admin_membership) do
      Repo.transaction(fn ->
        update_group_membership(user_membership, %{role: "Owner"})
        update_group_membership(admin_membership, %{role: "Admin"})

        query =
          from g in Group,
            where: g.id == ^group.id

        Repo.update_all(query, set: [owner_id: user.id])
      end)
    else
      false -> {:error, :not_an_admin}
      _ -> {:error, :could_not_kick_user}
    end
  end

  def remove_admin(user_id, group_id, admin) do
    with group = %{id: _id} <- get_group(group_id),
         user = %{id: _id} <- get_user(user_id),
         user_membership = %{id: _id} <- group_membership(group, user),
         admin_membership = %{id: _id} <- group_membership(group, admin),
         true <- GroupMembership.owner?(admin_membership) do
      update_group_membership(user_membership, %{role: "User"})
    else
      false -> {:error, :not_the_owner}
      _ -> {:error, :could_not_kick_user}
    end
  end

  def join_group(user, group_id, join_code) do
    with group = %{join_code: ^join_code} <- get_group(group_id) do
      create_group_membership(%{role: "User", group: group, user: user})
    end
  end

  def leave_group(user, group_id) do
    with group = %{id: _} <- get_group(group_id),
         membership = %{id: _} <- group_membership(group, user),
         false <- GroupMembership.owner?(membership) do
      delete_group_membership(membership)
    else
      true -> {:error, :owner_cant_leave}
      e = {:error, _} -> e
      _ -> {:error, :could_not_leave}
    end
  end

  def change_include_data(user_id, group_id, admin, include_data) do
    change_membership(user_id, group_id, admin, %{include_data: include_data})
  end

  def change_membership(user_id, group_id, admin, attrs) do
    with group = %{id: _id} <- get_group(group_id),
         user = %{id: _id} <- get_user(user_id),
         user_membership = %{id: _id} <- group_membership(group, user),
         admin_membership = %{id: _id} <- group_membership(group, admin),
         true <- GroupMembership.admin?(admin_membership) do
      update_group_membership(user_membership, attrs)
    else
      false -> {:error, :not_an_admin}
      _ -> {:error, :could_not_change_user}
    end
  end
end
