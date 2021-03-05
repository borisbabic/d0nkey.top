defmodule Backend.Fantasy do
  @moduledoc """
  The Fantasy context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.Fantasy.League

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of leagues using filtrex
  filters.

  ## Examples

      iex> list_leagues(%{})
      %{leagues: [%League{}], ...}
  """
  @spec paginate_leagues(map) :: {:ok, map} | {:error, any}
  def paginate_leagues(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:leagues), params["league"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_leagues(filter, params) do
      {:ok,
       %{
         leagues: page.entries,
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

  defp do_paginate_leagues(filter, params) do
    League
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of leagues.

  ## Examples

      iex> list_leagues()
      [%League{}, ...]

  """
  def list_leagues do
    Repo.all(League)
  end

  @doc """
  Gets a single league.

  Raises `Ecto.NoResultsError` if the League does not exist.

  ## Examples

      iex> get_league!(123)
      %League{}

      iex> get_league!(456)
      ** (Ecto.NoResultsError)

  """
  def get_league!(id), do: Repo.get!(League, id)

  @doc """
  Creates a league.

  ## Examples

      iex> create_league(%{field: value})
      {:ok, %League{}}

      iex> create_league(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_league(attrs \\ %{}) do
    %League{}
    |> League.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a league.

  ## Examples

      iex> update_league(league, %{field: new_value})
      {:ok, %League{}}

      iex> update_league(league, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_league(%League{} = league, attrs) do
    league
    |> League.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a League.

  ## Examples

      iex> delete_league(league)
      {:ok, %League{}}

      iex> delete_league(league)
      {:error, %Ecto.Changeset{}}

  """
  def delete_league(%League{} = league) do
    Repo.delete(league)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking league changes.

  ## Examples

      iex> change_league(league)
      %Ecto.Changeset{source: %League{}}

  """
  def change_league(%League{} = league, attrs \\ %{}) do
    League.changeset(league, attrs)
  end

  defp filter_config(:leagues) do
    defconfig do
      text(:name)
      text(:competition)
      text(:competition_type)
      text(:point_system)
      number(:max_teams)
      number(:roster_size)
    end
  end
end
