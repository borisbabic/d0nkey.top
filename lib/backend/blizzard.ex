defmodule Backend.Blizzard do
  @moduledoc false
  @type tour_stop ::
          :"Las Vegas" | :Seoul | :Bucharest | :Arlington | :Indonesia | :Jonkoping | :Montreal
  @tour_stops [:"Las Vegas", :Seoul, :Bucharest, :Arlington, :Indonesia, :Jonkoping, :Montreal]

  @doc """
  Gets the year and month from a season_id

  ## Example
    iex> Backend.Blizzard.get_month_start(75)
    ~D[2020-01-01]
    iex> Backend.Blizzard.get_month_start(74)
    ~D[2020-12-01]
  """
  @spec get_month_start(integer) :: Date.t()
  def get_month_start(season_id) do
    month = Util.normalize_month(rem(season_id - 62, 12))
    year = 2019 + div(season_id - month - 62, 12)

    case Date.new(year, month, 1) do
      {:ok, date} -> date
      # this should never happen
      {:error, reason} -> throw(reason)
    end
  end

  @doc """
  Gets the season id for a date

  ## Example
    iex> Backend.Blizzard.get_season_id(~D[2019-12-01])
    74
    iex> Backend.Blizzard.get_season_id(~D[2019-01-31])
    75
  """
  @spec get_season_id(Calendar.date() | %{month: number, year: number}) :: number
  def get_season_id(date) do
    62 + (date.year - 2019) * 12 + date.month
  end

  @doc """
  Gets the tour stop a ladder season qualifies for

  ## Example
    iex> Backend.Blizzard.get_ladder_tour_stop(72)
    {:ok, :Arlington}
    iex> Backend.Blizzard.get_ladder_tour_stop(79)
    {:ok, :Montreal}
  """
  @spec get_ladder_tour_stop(integer()) :: {:ok, tour_stop} | {:error, String.t()}
  def get_ladder_tour_stop(season_id) do
    case season_id do
      72 -> {:ok, :Arlington}
      73 -> {:ok, :Arlington}
      74 -> {:ok, :Indonesia}
      75 -> {:ok, :Indonesia}
      # I assume
      76 -> {:ok, :Jonkoping}
      # I assume
      77 -> {:ok, :Jonkoping}
      # I assume
      78 -> {:ok, :Montreal}
      # I assume
      79 -> {:ok, :Montreal}
      _ -> {:error, "Invalid tour stop for ladder"}
    end
  end

  @doc """
  Gets the season ids of ladder qualifying seasons for a tour stop

  ## Example
    iex> Backend.Blizzard.get_ladder_tour_stop(72)
    {:ok, :Arlington}
    iex> Backend.Blizzard.get_ladder_tour_stop(79)
    {:ok, :Montreal}
  """
  @spec get_ladder_tour_stop(tour_stop) :: {:ok, [integer()]} | {:error, String.t()}
  def get_ladder_seasons(tour_stop) do
    no_ladder_for_tour = {:error, "There were no ladder invites for this tour stop"}

    case tour_stop do
      :LasVegas -> no_ladder_for_tour
      :Seoul -> no_ladder_for_tour
      :Bucharest -> no_ladder_for_tour
      :Arlington -> {:ok, [72, 73]}
      :Indonesia -> {:ok, [74, 75]}
      :Jonkoping -> {:ok, [76, 77]}
      :Montreal -> {:ok, [78, 79]}
      _ -> {:error, "Unknown tour stop #{tour_stop}"}
    end
  end

  @doc """
  Returns a list of all tour stops
  """
  @spec tour_stops() :: [tour_stop]
  def tour_stops() do
    @tour_stops
  end
end
