defmodule Backend.Fantasy do
  @moduledoc """
  The Fantasy context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.Fantasy.League
  alias Backend.UserManager.User

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
    from(l in League)
    |> preload([:owner])
    |> Repo.all()
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
  def get_league!(id), do: Repo.get!(League, id) |> Repo.preload(:owner)

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

  def create_league(attrs, owner_id) do
    owner = Backend.UserManager.get_user!(owner_id)

    attrs
    |> Map.put(owner_key(attrs), owner)
    |> create_league()
  end

  defp owner_key(%{name: _}), do: :owner
  defp owner_key(%{"name" => _}), do: "owner"

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

  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.Fantasy.LeagueTeam

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of league_teams using filtrex
  filters.

  ## Examples

      iex> list_league_teams(%{})
      %{league_teams: [%LeagueTeam{}], ...}
  """
  @spec paginate_league_teams(map) :: {:ok, map} | {:error, any}
  def paginate_league_teams(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:league_teams), params["league_team"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_league_teams(filter, params) do
      {:ok,
       %{
         league_teams: page.entries,
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

  defp do_paginate_league_teams(filter, params) do
    LeagueTeam
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of league_teams.

  ## Examples

      iex> list_league_teams()
      [%LeagueTeam{}, ...]

  """
  def list_league_teams do
    Repo.all(LeagueTeam)
  end

  @doc """
  Gets a single league_team.

  Raises `Ecto.NoResultsError` if the League team does not exist.

  ## Examples

      iex> get_league_team!(123)
      %LeagueTeam{}

      iex> get_league_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_league_team!(id), do: Repo.get!(LeagueTeam, id)

  @doc """
  Creates a league_team.

  ## Examples

      iex> create_league_team(%{field: value})
      {:ok, %LeagueTeam{}}

      iex> create_league_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_league_team(attrs \\ %{}) do
    %LeagueTeam{}
    |> LeagueTeam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a league_team.

  ## Examples

      iex> update_league_team(league_team, %{field: new_value})
      {:ok, %LeagueTeam{}}

      iex> update_league_team(league_team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_league_team(%LeagueTeam{} = league_team, attrs) do
    league_team
    |> LeagueTeam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a LeagueTeam.

  ## Examples

      iex> delete_league_team(league_team)
      {:ok, %LeagueTeam{}}

      iex> delete_league_team(league_team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_league_team(%LeagueTeam{} = league_team) do
    Repo.delete(league_team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking league_team changes.

  ## Examples

      iex> change_league_team(league_team)
      %Ecto.Changeset{source: %LeagueTeam{}}

  """
  def change_league_team(%LeagueTeam{} = league_team, attrs \\ %{}) do
    LeagueTeam.changeset(league_team, attrs)
  end

  defp filter_config(:league_teams) do
    defconfig do
    end
  end

  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.Fantasy.LeagueTeamPick

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of league_team_picks using filtrex
  filters.

  ## Examples

      iex> list_league_team_picks(%{})
      %{league_team_picks: [%LeagueTeamPick{}], ...}
  """
  @spec paginate_league_team_picks(map) :: {:ok, map} | {:error, any}
  def paginate_league_team_picks(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
             filter_config(:league_team_picks),
             params["league_team_pick"] || %{}
           ),
         %Scrivener.Page{} = page <- do_paginate_league_team_picks(filter, params) do
      {:ok,
       %{
         league_team_picks: page.entries,
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

  defp do_paginate_league_team_picks(filter, params) do
    LeagueTeamPick
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of league_team_picks.

  ## Examples

      iex> list_league_team_picks()
      [%LeagueTeamPick{}, ...]

  """
  def list_league_team_picks do
    Repo.all(LeagueTeamPick)
  end

  @doc """
  Gets a single league_team_pick.

  Raises `Ecto.NoResultsError` if the League team pick does not exist.

  ## Examples

      iex> get_league_team_pick!(123)
      %LeagueTeamPick{}

      iex> get_league_team_pick!(456)
      ** (Ecto.NoResultsError)

  """
  def get_league_team_pick!(id), do: Repo.get!(LeagueTeamPick, id)

  @doc """
  Creates a league_team_pick.

  ## Examples

      iex> create_league_team_pick(%{field: value})
      {:ok, %LeagueTeamPick{}}

      iex> create_league_team_pick(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_league_team_pick(attrs \\ %{}) do
    %LeagueTeamPick{}
    |> LeagueTeamPick.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a league_team_pick.

  ## Examples

      iex> update_league_team_pick(league_team_pick, %{field: new_value})
      {:ok, %LeagueTeamPick{}}

      iex> update_league_team_pick(league_team_pick, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_league_team_pick(%LeagueTeamPick{} = league_team_pick, attrs) do
    league_team_pick
    |> LeagueTeamPick.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a LeagueTeamPick.

  ## Examples

      iex> delete_league_team_pick(league_team_pick)
      {:ok, %LeagueTeamPick{}}

      iex> delete_league_team_pick(league_team_pick)
      {:error, %Ecto.Changeset{}}

  """
  def delete_league_team_pick(%LeagueTeamPick{} = league_team_pick) do
    Repo.delete(league_team_pick)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking league_team_pick changes.

  ## Examples

      iex> change_league_team_pick(league_team_pick)
      %Ecto.Changeset{source: %LeagueTeamPick{}}

  """
  def change_league_team_pick(%LeagueTeamPick{} = league_team_pick, attrs \\ %{}) do
    LeagueTeamPick.changeset(league_team_pick, attrs)
  end

  defp filter_config(:league_team_picks) do
    defconfig do
      text(:pick)
    end
  end

  @spec get_user_leagues(User.t()) :: [League.t()]
  def get_user_leagues(%User{} = user) do
    query =
      from l in League,
        left_join: lt in LeagueTeam,
        on: [league_id: l.id],
        where: l.owner_id == ^user.id or lt.owner_id == ^user.id

    query |> Repo.all()
  end
end
