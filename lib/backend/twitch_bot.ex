defmodule Backend.TwitchBot do
    @moduledoc """
    The TwitchBot context.
    """

    import Ecto.Query, warn: false
    alias Backend.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias Backend.TwitchBot.TwitchCommand
  alias Backend.UserManager.User

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of twitch_commands using filtrex
  filters.

  ## Examples

      iex> list_twitch_commands(%{})
      %{twitch_commands: [%TwitchCommand{}], ...}
  """
  @spec paginate_twitch_commands(map) :: {:ok, map} | {:error, any}
  def paginate_twitch_commands(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:twitch_commands), params["twitch_command"] || %{}),
        %Scrivener.Page{} = page <- do_paginate_twitch_commands(filter, params) do
      {:ok,
        %{
          twitch_commands: page.entries,
          page_number: page.page_number,
          page_size: page.page_size,
          total_pages: page.total_pages,
          total_entries: page.total_entries,
          distance: @pagination_distance,
          sort_field: sort_field,
          sort_direction: sort_direction
        }
      }
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_twitch_commands(filter, params) do
    TwitchCommand
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of twitch_commands.

  ## Examples

      iex> list_twitch_commands()
      [%TwitchCommand{}, ...]

  """
  def list_twitch_commands do
    Repo.all(TwitchCommand)
  end

  @doc """
  Gets a single twitch_command.

  Raises `Ecto.NoResultsError` if the Twitch command does not exist.

  ## Examples

      iex> get_twitch_command!(123)
      %TwitchCommand{}

      iex> get_twitch_command!(456)
      ** (Ecto.NoResultsError)

  """
  def get_twitch_command!(id), do: Repo.get!(TwitchCommand, id)

  def get_twitch_command(id), do: Repo.get(TwitchCommand, id)

  @doc """
  Creates a twitch_command.

  ## Examples

      iex> create_twitch_command(%{field: value})
      {:ok, %TwitchCommand{}}

      iex> create_twitch_command(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_twitch_command(attrs \\ %{}) do
    %TwitchCommand{}
    |> TwitchCommand.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a twitch_command.

  ## Examples

      iex> update_twitch_command(twitch_command, %{field: new_value})
      {:ok, %TwitchCommand{}}

      iex> update_twitch_command(twitch_command, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_twitch_command(%TwitchCommand{} = twitch_command, attrs) do
    twitch_command
    |> TwitchCommand.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TwitchCommand.

  ## Examples

      iex> delete_twitch_command(twitch_command)
      {:ok, %TwitchCommand{}}

      iex> delete_twitch_command(twitch_command)
      {:error, %Ecto.Changeset{}}

  """
  def delete_twitch_command(%TwitchCommand{} = twitch_command) do
    Repo.delete(twitch_command)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking twitch_command changes.

  ## Examples

      iex> change_twitch_command(twitch_command)
      %Ecto.Changeset{source: %TwitchCommand{}}

  """
  def change_twitch_command(%TwitchCommand{} = twitch_command, attrs \\ %{}) do
    TwitchCommand.changeset(twitch_command, attrs)
  end

  @spec commands(twitch_chat :: String.t()) :: [TwitchCommand.t()]
  def commands(chat) do
    query = from tc in TwitchCommand,
      inner_join: u in assoc(tc, :user),
      inner_join: s in Backend.Streaming.Streamer,
      on: s.twitch_id == fragment("?::INTEGER", u.twitch_id),
      where: ilike(^chat, s.twitch_login) or ilike(^chat, s.hsreplay_twitch_login)

    Repo.all(query)
  end
  @spec user_commands(user :: User.t() | user_id :: integer()) :: [TwitchCommand.t()]
  def user_commands(%{id: id}), do: user_commands(id)
  def user_commands(id) do
    query = from tc in TwitchCommand,
      where: tc.user_id == ^id

    Repo.all(query)
  end

  def enable(id, user) do
    with command = %{id: _} = get_twitch_command(id),
      true <- can_manage?(command, user) do
        update_twitch_command(command, %{enabled: true})
    end
  end

  def disable(id, user) do
    with command = %{id: _} = get_twitch_command(id),
      true <- can_manage?(command, user) do
        update_twitch_command(command, %{enabled: false})
    end
  end

  def delete(id, user) do
    with command = %{id: _} = get_twitch_command(id),
      true <- can_manage?(command, user) do
        delete_twitch_command(command)
    end
  end

  @spec can_manage?(TwitchCommand.t(), User.t() |nil) :: boolean
  def can_manage?(%{user_id: user_id}, %{id: id}) when id == user_id, do: true
  def can_manage?(_, user = %{id: id}), do: User.can_access?(user, "twitch_commands")
  def can_manage?(_, _), do: false


  defp filter_config(:twitch_commands) do
    defconfig do
      text :type
        text :name
        boolean :enabled
        text :message
        text :response
        boolean :message_regex
        text :message_regex_flags
        text :sender
        boolean :sender_regex
        text :sender_regex_flags
        number :user_id
        #TODO add config for random_chance of type float

    end
  end
end
