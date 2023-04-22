defmodule Backend.TournamentStreams do
  @moduledoc """
  The TournamentStreams context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4, strip_unset_booleans: 3]
  import Filtrex.Type.Config

  alias Backend.TournamentStreams.TournamentStream

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of tournament_streams using filtrex
  filters.

  ## Examples

      iex> paginate_tournament_streams(%{})
      %{tournament_streams: [%TournamentStream{}], ...}

  """
  @spec paginate_tournament_streams(map) :: {:ok, map} | {:error, any}
  def paginate_tournament_streams(params \\ %{}) do
    params =
      params
      |> strip_unset_booleans("tournament_stream", [])
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
             filter_config(:tournament_streams),
             params["tournament_stream"] || %{}
           ),
         %Scrivener.Page{} = page <- do_paginate_tournament_streams(filter, params) do
      {:ok,
       %{
         tournament_streams: page.entries,
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

  defp do_paginate_tournament_streams(filter, params) do
    TournamentStream
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of tournament_streams.

  ## Examples

      iex> list_tournament_streams()
      [%TournamentStream{}, ...]

  """
  def list_tournament_streams do
    Repo.all(TournamentStream)
  end

  @doc """
  Gets a single tournament_stream.

  Raises `Ecto.NoResultsError` if the Tournament stream does not exist.

  ## Examples

      iex> get_tournament_stream!(123)
      %TournamentStream{}

      iex> get_tournament_stream!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament_stream!(id), do: Repo.get!(TournamentStream, id)

  @doc """
  Creates a tournament_stream.

  ## Examples

      iex> create_tournament_stream(%{field: value})
      {:ok, %TournamentStream{}}

      iex> create_tournament_stream(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tournament_stream(attrs \\ %{}) do
    %TournamentStream{}
    |> TournamentStream.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tournament_stream.

  ## Examples

      iex> update_tournament_stream(tournament_stream, %{field: new_value})
      {:ok, %TournamentStream{}}

      iex> update_tournament_stream(tournament_stream, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tournament_stream(%TournamentStream{} = tournament_stream, attrs) do
    tournament_stream
    |> TournamentStream.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TournamentStream.

  ## Examples

      iex> delete_tournament_stream(tournament_stream)
      {:ok, %TournamentStream{}}

      iex> delete_tournament_stream(tournament_stream)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tournament_stream(%TournamentStream{} = tournament_stream) do
    Repo.delete(tournament_stream)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tournament_stream changes.

  ## Examples

      iex> change_tournament_stream(tournament_stream)
      %Ecto.Changeset{source: %TournamentStream{}}

  """
  def change_tournament_stream(%TournamentStream{} = tournament_stream, attrs \\ %{}) do
    TournamentStream.changeset(tournament_stream, attrs)
  end

  defp filter_config(:tournament_streams) do
    defconfig do
      text(:tournament_source)
      text(:tournament_id)
      text(:streaming_platform)
      text(:stream_id)
    end
  end

  def get_for_tournament(tournament_tuple, user) do
    tournament_tuple
    |> get_for_tournament_query()
    |> Repo.all()
  end

  defp get_for_tournament_query({source, id}) do
    query =
      from ts in TournamentStream,
        where: ts.tournament_source == ^source and ts.tournament_id == ^id
  end

  def get_for_tournament_user(tournament_tuple, user) do
    tournament_tuple
    |> get_for_tournament_query()
    |> where([ts], ts.user_id == ^user.id)
    |> Repo.all()
  end
end
