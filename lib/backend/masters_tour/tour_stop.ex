defmodule Backend.MastersTour.TourStop do
  @moduledoc false
  import TypedStruct
  alias Backend.Blizzard

  defmacro is_tour_stop(tour_stop) do
    quote do
      unquote(tour_stop) in [
        :"Las Vegas",
        :Seoul,
        :Bucharest,
        :Arlington,
        :Indonesia,
        :Jönköping,
        :"Asia-Pacific",
        :Montréal,
        :Madrid
      ]
    end
  end

  typedstruct enforce: true do
    field :id, :atom
    field :battlefy_id, Backend.Battlefy.tournament_id(), enforce: false
    field :ladder_seasons, [integer]
    field :region, Blizzard.region()
    field :start_time, NaiveDateTime.t(), enforce: false
    field :old_id, atom, enforce: false
    field :year, integer
  end

  def all() do
    [
      %__MODULE__{
        id: :"Las Vegas",
        battlefy_id: "5cdb04cdce130203069be2dd",
        ladder_seasons: [],
        region: :US,
        start_time: ~N[2019-06-14 16:00:00],
        year: 2020
      },
      %__MODULE__{
        id: :Seoul,
        battlefy_id: "5d3117357045a2325e167ad6",
        ladder_seasons: [],
        region: :AP,
        start_time: ~N[2019-08-16 01:00:00],
        year: 2019
      },
      %__MODULE__{
        id: :Bucharest,
        battlefy_id: "5d8276701d82bf1a20dbf45b",
        ladder_seasons: [],
        region: :EU,
        start_time: ~N[2019-10-18 06:00:00],
        year: 2020
      },
      %__MODULE__{
        id: :Arlington,
        battlefy_id: "5e1cf8ff1e66fd33ebbfc0ed",
        ladder_seasons: [72, 73],
        region: :US,
        start_time: ~N[2020-01-31 15:00:00],
        year: 2020
      },
      %__MODULE__{
        id: :Indonesia,
        battlefy_id: "5e5d80217506f5240ebad221",
        ladder_seasons: [74, 75],
        region: :AP,
        start_time: ~N[2020-03-20 16:00:00],
        year: 2020
      },
      %__MODULE__{
        id: :Jönköping,
        battlefy_id: "5ec5ca7153702b1ab2a5c9dd",
        ladder_seasons: [76, 77],
        region: :EU,
        start_time: ~N[2020-06-12 12:15:00],
        year: 2020
      },
      %__MODULE__{
        id: :"Asia-Pacific",
        battlefy_id: "5efbcdaca2b8f022508f65c3",
        ladder_seasons: [78, 79],
        region: :AP,
        start_time: ~N[2020-07-17 00:00:00],
        year: 2020
      },
      %__MODULE__{
        id: :Montréal,
        battlefy_id: "5f3c3c6066bf242962711d60",
        ladder_seasons: [80, 81],
        region: :US,
        old_id: :Montreal,
        start_time: ~N[2020-09-11 15:15:00],
        year: 2020
      },
      %__MODULE__{
        id: :Madrid,
        battlefy_id: "5f8100994e9faf3dd1a80ad0",
        ladder_seasons: [82, 83],
        region: :EU,
        start_time: ~N[2020-10-23 12:15:00],
        year: 2020
      },
      %__MODULE__{
        id: :TBD_2021_1,
        battlefy_id: nil,
        ladder_seasons: [87],
        region: :US,
        start_time: ~N[2021-10-23 12:15:00],
        year: 2021
      }
    ]
  end

  def get(tour_stop, attr) when is_tour_stop(tour_stop) and is_atom(attr) do
    tour_stop
    |> get()
    |> Access.get(attr)
  end

  def get_battlefy_id(tour_stop) when is_tour_stop(tour_stop) do
    id_unknown = {:error, "ID unknown for tour stop #{tour_stop}}"}

    case get(tour_stop) do
      nil -> raise "Unknown tour stop #{tour_stop}"
      %{battlefy_id: battlefy_id} when is_binary(battlefy_id) -> {:ok, battlefy_id}
      _ -> id_unknown
    end
  end

  def get_battlefy_id!(tour_stop), do: get_battlefy_id(tour_stop) |> Util.bangify()

  @doc """
  Gets the tour stop a ladder season qualifies for

  ## Example
    iex> Backend.MastersTour.TourStop.get_id_for_season(72)
    {:ok, :Arlington}
    iex> Backend.MastersTour.TourStop.get_id_for_season(79)
    {:ok, :"Asia-Pacific"}
  """
  @spec get_id_for_season(integer()) :: {:ok, Blizzard.tour_stop()} | {:error, String.t()}
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_id_for_season(season_id) when is_integer(season_id) do
    all()
    |> Enum.find(fn ts -> Enum.member?(ts.ladder_seasons, season_id) end)
    |> case do
      %{id: id} -> {:ok, id}
      _ -> {:error, "No tour stop for ladder season #{season_id}"}
    end
  end

  def get_id_for_season!(season_id), do: Util.bangify(get_id_for_season(season_id))

  def get(tour_stop) when is_tour_stop(tour_stop) do
    all()
    |> Enum.find(fn ts -> ts.id == tour_stop end)
  end

  def get(tour_stop) when is_binary(tour_stop) do
    all()
    |> Enum.find(fn ts -> to_string(ts.id) == tour_stop end)
  end

  def get_current(hours_before_start \\ 1, hours_after_start \\ 96) do
    now = NaiveDateTime.utc_now()

    all()
    |> Enum.find_value(fn ts ->
      lower = NaiveDateTime.add(ts.start_time, hours_before_start * -3600)
      upper = NaiveDateTime.add(ts.start_time, hours_after_start * 3600)
      Util.in_range?(now, {lower, upper}) && ts.id
    end)
  end

  @spec started?(atom | String.t() | Backend.MastersTour.TourStop.t()) :: boolean
  def started?(%{start_time: start_time}),
    do: NaiveDateTime.compare(start_time, NaiveDateTime.utc_now()) == :lt

  def started?(tour_stop) when is_atom(tour_stop) or is_binary(tour_stop),
    do: tour_stop |> get() |> started?()
end
