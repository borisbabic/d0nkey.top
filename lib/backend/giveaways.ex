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
    result =
      giveaway
      |> Giveaway.changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, updated_giveaway} ->
        if Map.has_key?(attrs, :codes) or Map.has_key?(attrs, "codes") do
          sync_codes_to_winners(updated_giveaway)
        end

        {:ok, updated_giveaway}

      error ->
        error
    end
  end

  @doc """
  Saves and normalizes codes for a giveaway, syncing them to winning entries.
  """
  @spec save_codes(Giveaway.t(), list(String.t()) | String.t()) :: {:ok, Giveaway.t()} | {:error, Ecto.Changeset.t()}
  def save_codes(%Giveaway{} = giveaway, codes_raw) do
    codes = Giveaway.normalize_codes(codes_raw)
    update_giveaway(giveaway, %{codes: codes})
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
    if Util.after_now?(deadline) do
      GiveawayEntry.changeset(%{user_id: user.id, giveaway_id: giveaway.id})
      |> Repo.insert()
    else
      {:error, :deadline_has_passed}
    end
  end

  def get_entries(%Giveaway{} = giveaway, %User{id: user_id}) do
    creator_id = giveaway.creator_id || (giveaway.creator && giveaway.creator.id)

    if user_id == creator_id do
      do_entries(giveaway)
    else
      []
    end
  end

  defp do_entries(%Giveaway{id: id}) do
    query =
      from ge in GiveawayEntry,
        inner_join: u in assoc(ge, :user),
        where: ge.giveaway_id == ^id,
        preload: [user: u]

    Repo.all(query)
  end

  def pick_winners(%Giveaway{number_of_winners: num} = giveaway, %User{id: user_id} = user) do
    creator_id = giveaway.creator_id || (giveaway.creator && giveaway.creator.id)

    if user_id == creator_id do
      entries = get_entries(giveaway, user)

      existing_winners =
        entries
        |> Enum.filter(& &1.winner)

      num_existing_winners = Enum.count(existing_winners)

      if num_existing_winners < num do
        new_winners =
          entries
          |> Enum.filter(&(!&1.winner))
          |> score_entries(giveaway)
          |> create_random_list()
          |> Enum.take(num - num_existing_winners)

        giveaway_reloaded = Repo.get!(Giveaway, giveaway.id)
        all_codes = giveaway_reloaded.codes || []

        used_codes =
          existing_winners
          |> Enum.map(& &1.code)
          |> Enum.reject(&is_nil/1)

        available_codes = all_codes -- used_codes

        multi =
          new_winners
          |> Enum.with_index()
          |> Enum.reduce(Multi.new(), fn {entry, idx}, multi ->
            assigned_code = Enum.at(available_codes, idx)
            cs = GiveawayEntry.changeset(entry, %{winner: true, code: assigned_code})
            Multi.update(multi, "make_#{entry.id}_a_winner", cs)
          end)

        Repo.transaction(multi)

        {:ok, get_entries(giveaway, user)}
      else
        {:ok, entries}
      end
    else
      {:error, :unauthorized}
    end
  end

  defp sync_codes_to_winners(%Giveaway{id: giveaway_id, codes: codes}) do
    query =
      from ge in GiveawayEntry,
        where: ge.giveaway_id == ^giveaway_id and ge.winner,
        order_by: [asc: ge.inserted_at, asc: ge.id]

    winners = Repo.all(query)
    codes = codes || []

    used_codes =
      winners
      |> Enum.map(& &1.code)
      |> Enum.filter(&(&1 in codes))

    {_, multi} =
      Enum.reduce(winners, {codes -- used_codes, Multi.new()}, fn entry, {avail_codes, multi} ->
        if entry.code in codes do
          {avail_codes, multi}
        else
          [next_code | rest_avail] = avail_codes ++ [nil]
          cs = GiveawayEntry.changeset(entry, %{code: next_code})
          {rest_avail, Multi.update(multi, "sync_winner_code_#{entry.id}", cs)}
        end
      end)

    Repo.transaction(multi)
  end

  @spec create_random_list([{score :: integer(), GiveawayEntry.t()}]) :: [GiveawayEntry.t()]
  defp create_random_list(scored_entries) do
    Enum.flat_map(scored_entries, fn {num, entry} ->
      for _ <- 1..num, do: entry
    end)
    |> Enum.shuffle()
    |> Enum.uniq()
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

  @default_leeway_hours 5

  @spec current_giveaway_id(number()) :: integer() | nil
  def current_giveaway_id(leeway_hours \\ @default_leeway_hours) do
    with %{id: id} when is_integer(id) <- current_giveaway(leeway_hours) do
      id
    end
  end

  @spec current_giveaway(number()) :: Giveaway.t() | nil
  def current_giveaway(leeway_hours \\ @default_leeway_hours) do
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

  def codes do
    case current_giveaway() do
      %Giveaway{codes: codes} when is_list(codes) and codes != [] -> codes
      _ -> Application.get_env(:backend, :giveaway_codes, [])
    end
  end

  def code, do: codes() |> Enum.at(0)

  def winner?(nil), do: false

  def winner?(%User{id: user_id}) do
    case current_giveaway() do
      %Giveaway{id: giveaway_id} ->
        winner?(giveaway_id, user_id)

      nil ->
        query =
          from ge in GiveawayEntry,
            where: ge.user_id == ^user_id and ge.winner,
            select: count(ge.id)

        Repo.one(query) > 0
    end
  end

  def winner?(_), do: false

  def winner?(%Giveaway{id: giveaway_id}, %User{id: user_id}), do: winner?(giveaway_id, user_id)

  def winner?(giveaway_id, user_id) when is_integer(giveaway_id) and is_integer(user_id) do
    query =
      from ge in GiveawayEntry,
        where: ge.giveaway_id == ^giveaway_id and ge.user_id == ^user_id and ge.winner,
        select: count(ge.id)

    Repo.one(query) > 0
  end

  def winner?(_, _), do: false
end
