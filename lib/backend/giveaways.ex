defmodule Backend.Giveaways do
  @moduledoc """
  The Giveaways context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.UserManager.User
  alias Backend.Repo

  alias Backend.Giveaways.Giveaway
  alias Backend.Giveaways.GiveawayEntry

  @doc """
  Returns the list of giveaways.

  ## Examples

      iex> list_giveaways()
      [%Giveaway{}, ...]

  """
  def list_giveaways do
    Repo.all(Giveaway)
  end

  @doc """
  Gets a single giveaway.

  Raises `Ecto.NoResultsError` if the Giveaway does not exist.

  ## Examples

      iex> get_giveaway!(123)
      %Giveaway{}

      iex> get_giveaway!(456)
      ** (Ecto.NoResultsError)

  """
  def get_giveaway!(id), do: Repo.get!(Giveaway, id) |> preload_giveaway()

  @spec preload_giveaway(Giveaway.t()) :: Giveaway.t()
  def preload_giveaway(giveaway), do: Repo.preload(giveaway, :creator)

  @doc """
  Creates a giveaway.
  """
  def create_giveaway(attrs_raw, %User{id: user_id}) do
    attrs = Map.put(attrs_raw, :creator_id, user_id)

    %Giveaway{}
    |> Giveaway.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a giveaway.

  ## Examples

      iex> update_giveaway(giveaway, %{field: new_value})
      {:ok, %Giveaway{}}

      iex> update_giveaway(giveaway, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_giveaway(%Giveaway{} = giveaway, attrs) do
    giveaway
    |> Giveaway.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a giveaway.

  ## Examples

      iex> delete_giveaway(giveaway)
      {:ok, %Giveaway{}}

      iex> delete_giveaway(giveaway)
      {:error, %Ecto.Changeset{}}

  """
  def delete_giveaway(%Giveaway{} = giveaway) do
    Repo.delete(giveaway)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking giveaway changes.

  ## Examples

      iex> change_giveaway(giveaway)
      %Ecto.Changeset{data: %Giveaway{}}

  """
  def change_giveaway(%Giveaway{} = giveaway, attrs \\ %{}) do
    Giveaway.changeset(giveaway, attrs)
  end

  @spec get_entry(Giveaway.t(), User.t()) :: GiveawayEntry.t() | nil
  def get_entry(_, nil), do: nil

  def get_entry(%Giveaway{} = giveaway, %User{} = user) do
    query =
      from ge in GiveawayEntry,
        where: ge.giveaway_id == ^giveaway.id and ge.user_id == ^user.id

    Repo.one(query)
  end

  @spec enter(Giveaway.t(), User.t()) :: {:ok, GiveawayEntry.t()} | {:error, atom() | Ecto.Changeset.t()}
  def enter(%{creator_id: creator_id}, %{id: user_id}) when user_id == creator_id do
    {:error, :creator_cant_enter_giveaway}
  end

  def enter(%Giveaway{deadline: deadline} = giveaway, %User{} = user) do
    if Util.after_now(deadline) do
      GiveawayEntry.changeset(%{user_id: user.id, giveaway_id: giveaway.id})
      |> Repo.insert()
    else
      {:error, :deadline_has_passed}
    end
  end

  def get_entries(%Giveaway{creator: %{id: creator_id}} = giveaway, %User{id: user_id}) when user_id == creator_id do
    do_entries(giveaway)
  end

  defp do_entries(%Giveaway{id: id}) do
    query =
      from ge in GiveawayEntry,
        inner_join: u in assoc(ge, :user),
        where: ge.giveaway_id == ^id,
        preload: [user: u]

    Repo.all(query)
  end

  def pick_winners(%Giveaway{creator: %{id: creator_id}, number_of_winners: num} = giveaway, %User{id: user_id} = user)
      when user_id == creator_id do
    entries = get_entries(giveaway, user)
    winners = Enum.count(entries, & &1.winner)

    if winners < num do
      entries
      |> Enum.filter(&(!&1.winner))
      |> score_entries(giveaway)
      |> create_random_list()
      |> Enum.take(num - winners)
      |> update_winners()

      {:ok, get_entries(giveaway, user)}
    else
      {:ok, entries}
    end
  end

  @spec create_random_list([{score :: integer(), GiveawayEntry.t()}]) :: [GiveawayEntry.t()]
  defp create_random_list(scored_entries) do
    Enum.flat_map(scored_entries, fn {num, entry} ->
      for _ <- 1..num, do: entry
    end)
    |> Enum.shuffle()
    |> Enum.uniq()
  end

  defp update_winners(entries) do
    multi =
      Enum.reduce(entries, Multi.new(), fn %{id: id, winner: false} = entry, multi ->
        cs = GiveawayEntry.changeset(entry, %{winner: true})
        Multi.update(multi, "make_#{id}_a_winner", cs)
      end)

    Repo.transaction(multi)
  end

  def score_entries(entries, _giveaway) do
    # todo make more flexible and check config
    Enum.map(entries, fn %{user: %{battletag: _battletag, country_code: cc}} = entry ->
      if cc do
        {2, entry}
      else
        {1, entry}
      end
    end)
  end

  @spec current_giveaway(number()) :: Giveaway.t() | nil
  def current_giveaway(leeway_hours \\ 6) do
    now = NaiveDateTime.utc_now()
    # keep it around for 6 arounds
    cutoff = Timex.shift(now, hours: -1 * leeway_hours)

    query =
      from g in Giveaway, where: g.creator_id == 1 and g.deadline > ^cutoff, order_by: [desc: g.deadline], limit: 1

    Repo.one(query)
  end

  @spec winner_names(Giveaway.t()) :: [String.t()]
  def winner_names(%Giveaway{id: id}) do
    query =
      from ge in GiveawayEntry,
        inner_join: u in assoc(ge, :user),
        where: ge.giveaway_id == ^id and ge.winner,
        select: u.battletag

    Repo.all(query)
    |> Enum.map(&Backend.Battlenet.Battletag.shorten/1)
  end
end
