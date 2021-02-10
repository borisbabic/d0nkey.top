defmodule Backend.Battlenet do
  @moduledoc """
  The Battlenet context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.Battlenet.Battletag
  alias Backend.PrioritizedBattletagCache

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
end
