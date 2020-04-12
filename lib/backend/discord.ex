defmodule Backend.Discord do
  @moduledoc false
  alias Backend.Repo
  alias Backend.Infrastructure.DiscordCommunicator, as: Api
  alias Backend.Discord.Broadcast

  def url() do
    "https://discordapp.com/api/webhooks/672113411731226634/q7F_sCtz6aCvF6wIB1qHEbsx-_aLnvHPC53Nol-SkfDfeKNHhD62gCFVeJ-7dPLnDx5p"
  end

  def broadcast(path, name) do
    Api.broadcast_file(path, name, url())
  end

  @spec broadcast(Broadcast.t(), String.t(), String.t()) :: any
  def broadcast(broadcast, path, name) do
    broadcast.subscribed_urls
    |> Enum.each(fn url -> Api.broadcast_file(path, name, url) end)
  end

  def subscribe(broadcast, url) do
    broadcast
    |> Broadcast.changeset(%{subscribed_urls: broadcast.subscribed_urls ++ [url]})
    |> Repo.update()
  end

  @doc """
  Returns the list of broadcasts.

  ## Examples

      iex> list_broadcasts()
      [%Broadcast{}, ...]

  """
  def list_broadcasts do
    Repo.all(Broadcast)
  end

  @doc """
  Gets a single broadcast.

  Raises `Ecto.NoResultsError` if the Broadcast does not exist.

  ## Examples

      iex> get_broadcast!(123)
      %Broadcast{}

      iex> get_broadcast!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_broadcast!(String.t()) :: Backend.Discord.Broadcast.t()
  def get_broadcast!(id), do: Repo.get!(Broadcast, id)

  def create_broadcast() do
    Broadcast.new()
    |> Repo.insert()
  end

  @doc """
  Creates a broadcast.

  ## Examples

      iex> create_broadcast(%{field: value})
      {:ok, %Broadcast{}}

      iex> create_broadcast(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_broadcast(attrs) do
    %Broadcast{}
    |> Broadcast.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a broadcast.

  ## Examples

      iex> update_broadcast(broadcast, %{field: new_value})
      {:ok, %Broadcast{}}

      iex> update_broadcast(broadcast, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_broadcast(broadcast = %Broadcast{}, attrs) do
    broadcast
    |> Broadcast.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Broadcast.

  ## Examples

      iex> delete_broadcast(broadcast)
      {:ok, %Broadcast{}}

      iex> delete_broadcast(broadcast)
      {:error, %Ecto.Changeset{}}

  """
  def delete_broadcast(broadcast = %Broadcast{}) do
    Repo.delete(broadcast)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking broadcast changes.

  ## Examples

      iex> change_broadcast(broadcast)
      %Ecto.Changeset{source: %Broadcast{}}

  """
  def change_broadcast(broadcast = %Broadcast{}) do
    Broadcast.changeset(broadcast, %{})
  end
end
