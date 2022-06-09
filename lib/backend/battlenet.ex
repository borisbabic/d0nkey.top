defmodule Backend.Battlenet do
  @moduledoc """
  The Battlenet context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.Battlenet.Battletag
  alias Backend.PrioritizedBattletagCache

  @self_reported_priority 9001

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of battletag_info using filtrex
  filters.

  ## Examples

      iex> list_battletag_info(%{})
      %{battletag_info: [%Battletag{}], ...}
  """
  @spec paginate_battletag_info(map) :: {:ok, map} | {:error, any}
  def paginate_battletag_info(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:battletag_info), params["battletag"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_battletag_info(filter, params) do
      {:ok,
       %{
         battletag_info: page.entries,
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

  defp do_paginate_battletag_info(filter, params) do
    Battletag
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of battletag_info.

  ## Examples

      iex> list_battletag_info()
      [%Battletag{}, ...]

  """
  def list_battletag_info do
    Repo.all(Battletag)
  end

  @doc """
  Gets a single battletag.

  Raises `Ecto.NoResultsError` if the Battletag does not exist.

  ## Examples

      iex> get_battletag!(123)
      %Battletag{}

      iex> get_battletag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_battletag!(id), do: Repo.get!(Battletag, id)

  @doc """
  Creates a battletag.

  ## Examples

      iex> create_battletag(%{field: value})
      {:ok, %Battletag{}}

      iex> create_battletag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_battletag(attrs \\ %{}) do
    %Battletag{}
    |> Battletag.changeset(attrs)
    |> Repo.insert()
    |> PrioritizedBattletagCache.update_cache()
  end

  @doc """
  Updates a battletag.

  ## Examples

      iex> update_battletag(battletag, %{field: new_value})
      {:ok, %Battletag{}}

      iex> update_battletag(battletag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_battletag(%Battletag{} = battletag, attrs) do
    battletag
    |> Battletag.changeset(attrs)
    |> Repo.update()
    |> PrioritizedBattletagCache.update_cache()
  end

  @doc """
  Deletes a Battletag.

  ## Examples

      iex> delete_battletag(battletag)
      {:ok, %Battletag{}}

      iex> delete_battletag(battletag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_battletag(%Battletag{} = battletag) do
    Repo.delete(battletag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking battletag changes.

  ## Examples

      iex> change_battletag(battletag)
      %Ecto.Changeset{source: %Battletag{}}

  """
  def change_battletag(%Battletag{} = battletag, attrs \\ %{}) do
    Battletag.changeset(battletag, attrs)
  end

  defp filter_config(:battletag_info) do
    defconfig do
      text(:battletag_full)
      text(:battletag_short)
      text(:country)
      number(:priority)
      text(:reported_by)
    end
  end

  @spec by_battletag_full(String.t()) :: Battletag.t() | nil
  def by_battletag_full(battletag_full),
    do: from(b in Battletag, where: b.battletag_full == ^battletag_full) |> by_battletag()

  @spec by_battletag_short(String.t()) :: Battletag.t() | nil
  def by_battletag_short(battletag_short),
    do: from(b in Battletag, where: b.battletag_short == ^battletag_short) |> by_battletag()

  @spec by_battletag(Query.t()) :: Battletag.t() | nil
  defp by_battletag(query) do
    query
    |> order_by([b], desc: b.priority)
    |> limit(1)
    |> Repo.one()
  end

  @spec update_user_country(Backend.UserManager.User.t()) :: any()
  def update_user_country(%{battletag: bt, country_code: cc}) when not is_nil(cc) do
    update_query =
      from(b in Battletag,
        where: b.battletag_full == ^bt and b.reported_by == ^bt
      )

    attrs = %{
      battletag_full: bt,
      reported_by: bt,
      country: cc,
      priority: @self_reported_priority
    }

    current? =
      from(b in Battletag,
        where:
          b.battletag_full == ^bt and b.reported_by == ^bt and b.country == ^cc and b.priority > 0
      )
      |> Repo.all()
      |> Enum.any?()

    if !current? do
      cs = %Battletag{} |> Battletag.changeset(attrs)

      Multi.new()
      |> Multi.update_all(:update_all, update_query, set: [priority: 0])
      |> Multi.insert(:new, cs)
      |> Repo.transaction()
    end
  end

  def update_user_country(_), do: nil
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.Battlenet.OldBattletag

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of old_battletags using filtrex
  filters.

  ## Examples

      iex> list_old_battletags(%{})
      %{old_battletags: [%OldBattletag{}], ...}
  """
  @spec paginate_old_battletags(map) :: {:ok, map} | {:error, any}
  def paginate_old_battletags(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:old_battletags), params["old_battletag"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_old_battletags(filter, params) do
      {:ok,
       %{
         old_battletags: page.entries,
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

  defp do_paginate_old_battletags(filter, params) do
    OldBattletag
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of old_battletags.

  ## Examples

      iex> list_old_battletags()
      [%OldBattletag{}, ...]

  """
  def list_old_battletags do
    Repo.all(OldBattletag)
  end

  @doc """
  Gets a single old_battletag.

  Raises `Ecto.NoResultsError` if the Old battletag does not exist.

  ## Examples

      iex> get_old_battletag!(123)
      %OldBattletag{}

      iex> get_old_battletag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_old_battletag!(id), do: Repo.get!(OldBattletag, id)

  @spec get_old_for_user(Backend.UserManager.User.t()) :: [OldBattletag.t()]
  def get_old_for_user(user) do
    query =
      from ob in OldBattletag,
        preload: :user,
        where: ob.user_id == ^user.id

    Repo.all(query)
  end

  def get_old_for_btag(btag) do
    query =
      from ob in OldBattletag,
        where:
          ^btag in [
            ob.old_battletag,
            ob.new_battletag,
            ob.old_battletag_short,
            ob.new_battletag_short
          ]

    Repo.all(query)
  end

  @doc """
  Creates a old_battletag.

  ## Examples

      iex> create_old_battletag(%{field: value})
      {:ok, %OldBattletag{}}

      iex> create_old_battletag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_old_battletag(attrs \\ %{}) do
    %OldBattletag{}
    |> OldBattletag.changeset(attrs)
    |> Repo.insert()
  end

  def battletag_change_changeset(%{battletag: battletag} = user, new_btag) do
    attrs = %{
      old_battletag: battletag,
      new_battletag: new_btag,
      user_id: user.id,
      source: "battlenet"
    }

    %OldBattletag{}
    |> OldBattletag.changeset(attrs)
  end

  @doc """
  Updates a old_battletag.

  ## Examples

      iex> update_old_battletag(old_battletag, %{field: new_value})
      {:ok, %OldBattletag{}}

      iex> update_old_battletag(old_battletag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_old_battletag(%OldBattletag{} = old_battletag, attrs) do
    old_battletag
    |> OldBattletag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a OldBattletag.

  ## Examples

      iex> delete_old_battletag(old_battletag)
      {:ok, %OldBattletag{}}

      iex> delete_old_battletag(old_battletag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_old_battletag(%OldBattletag{} = old_battletag) do
    Repo.delete(old_battletag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking old_battletag changes.

  ## Examples

      iex> change_old_battletag(old_battletag)
      %Ecto.Changeset{source: %OldBattletag{}}

  """
  def change_old_battletag(%OldBattletag{} = old_battletag, attrs \\ %{}) do
    OldBattletag.changeset(old_battletag, attrs)
  end

  defp filter_config(:old_battletags) do
    defconfig do
      text(:new_battletag)
      text(:old_battletag)
      text(:source)
    end
  end
end
