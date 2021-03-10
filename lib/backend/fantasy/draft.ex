defmodule Backend.Fantasy.Draft do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Fantasy.Draft
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam

  schema "fantasy_drafts" do
    belongs_to :league, League
    field :time_per_pick, :integer
    field :pick_order, {:array, :integer}, default: []
    field :current_pick_number, :integer, default: 0
    field :last_pick_at, :utc_datetime
  end

  @doc false
  def changeset(draft, attrs) do
    draft
    |> cast(
      attrs,
      [
        :time_per_pick,
        :pick_order,
        :current_pick_number,
        :last_pick_at
      ]
    )
    |> set_league(attrs)
    |> validate_required([:league])
  end

  @doc false
  def set_pick_order(draft, lt) do
    draft
    |> cast(%{pick_order: generate_pick_order(draft, lt)}, [:pick_order])
  end

  defp generate_pick_order(%{league: %{roster_size: roster_size}}, lt) do
    forward = lt |> Enum.map(& &1.id) |> Enum.random()
    reverse = forward |> Enum.reverse()

    1..roster_size
    |> Enum.flat_map(fn i ->
      if rem(i, 2) == 0 do
        forward
      else
        reverse
      end
    end)
  end

  @spec add_pick(__MODULE__, LeagueTeam.t()) ::
          {:ok, Ecto.Changeset.t()} | {:ok, __MODULE__} | {:error, atom()}
  def add_pick(draft = %Draft{}, picked_by) do
    with true <- picked_on_time?(draft),
         current_picker when is_integer(current_picker) <-
           draft.pick_order[draft.current_pick_number],
         true <- current_picker == picked_by.id do
      {
        :ok,
        draft
        |> cast(
          %{
            current_pick_number: draft.current_pick_number + 1,
            last_pick_at: NaiveDateTime.utc_now()
          },
          [:current_pick_number, :last_pick_at]
        )
      }
    else
      nil -> {:error, :out_of_picks}
      false -> {:error, :invalid_pick}
    end
  end

  @spec right_picker?(__MODULE__, LeagueTeam.t()) :: boolean()
  def right_picker?(draft, %{id: id}), do: draft.pick_order[draft.current_pick_number] == id

  @spec picked_on_time?(__MODULE__) :: boolean()
  def picked_on_time?(%Draft{time_per_pick: 0}), do: true

  def picked_on_time?(%Draft{time_per_pick: seconds, last_pick_at: last}) do
    deadline = last |> NaiveDateTime.add(seconds)
    now = NaiveDateTime.utc_now()
    NaiveDateTime.compare(deadline, now) != :lt
  end

  defp set_league(c, %{league: league}), do: set_league(c, league)
  defp set_league(c, %{"league" => league}), do: set_league(c, league)

  defp set_league(c, league = %{id: _}) do
    c
    |> put_assoc(:league, league)
    |> foreign_key_constraint(:league)
  end

  defp set_league(c, _), do: c
end
