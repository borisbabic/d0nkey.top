defmodule Backend.Blizzard do
  @moduledoc false
  @type tour_stop ::
          :"Las Vegas" | :Seoul | :Bucharest | :Arlington | :Indonesia | :Jönköping | :Montreal
  @tour_stops [:"Las Vegas", :Seoul, :Bucharest, :Arlington, :Indonesia, :Jönköping, :Montreal]

  @type region :: :EU | :US | :AP
  @regions [:EU, :US, :AP]
  @type leaderboard :: :BG | :STD | :WLD
  @leaderboards [:BG, :STD, :WLD]

  @doc """
  Gets the year and month from a season_id

  ## Example
    iex> Backend.Blizzard.get_month_start(75)
    ~D[2020-01-01]
    iex> Backend.Blizzard.get_month_start(74)
    ~D[2019-12-01]
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
    iex> Backend.Blizzard.get_season_id(~D[2020-01-31])
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
      76 -> {:ok, :Jönköping}
      # I assume
      77 -> {:ok, :Jönköping}
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
    iex> Backend.Blizzard.get_ladder_seasons(:Montreal)
    {:ok, [78, 79]}
    iex> Backend.Blizzard.get_ladder_seasons(:Bucharest)
    {:error, "There were no ladder invites for this tour stop"}
  """
  @spec get_ladder_seasons(tour_stop) :: {:ok, [integer()]} | {:error, String.t()}
  def get_ladder_seasons(tour_stop) do
    no_ladder_for_tour = {:error, "There were no ladder invites for this tour stop"}

    case tour_stop do
      :LasVegas -> no_ladder_for_tour
      :Seoul -> no_ladder_for_tour
      :Bucharest -> no_ladder_for_tour
      :Arlington -> {:ok, [72, 73]}
      :Indonesia -> {:ok, [74, 75]}
      :Jönköping -> {:ok, [76, 77]}
      :Montreal -> {:ok, [78, 79]}
      _ -> {:error, "Unknown tour stop #{tour_stop}"}
    end
  end

  @spec current_ladder_tour_stop() :: tour_stop
  def current_ladder_tour_stop() do
    case get_ladder_tour_stop(get_season_id(Date.utc_today())) do
      {:ok, ts} -> ts
      {:error, _} -> ""
    end
  end

  @doc """
  Returns a list of all tour stops
  """
  @spec tour_stops() :: [tour_stop]
  def tour_stops() do
    @tour_stops
  end

  @doc """
  Returns a list of all tour stops as strings
  """
  @spec tour_stops(:string) :: [String.t()]
  def tour_stops(:string) do
    Enum.map(@tour_stops, &to_string/1)
  end

  @doc """
  Returns a list of all leaderboards
  """
  @spec leaderboards() :: [leaderboard]
  def leaderboards() do
    @leaderboards
  end

  @doc """
  Returns a list of all leaderboards as strings
  """
  @spec leaderboards(:string) :: [String.t()]
  def leaderboards(:string) do
    Enum.map(@leaderboards, &to_string/1)
  end

  @doc """
  Returns a list of all regions
  """
  @spec regions() :: [region]
  def regions() do
    @regions
  end

  @doc """
  Returns a list of all regions as strings
  """
  @spec regions(:string) :: [String.t()]
  def regions(:string) do
    Enum.map(@regions, &to_string/1)
  end

  @spec to_leaderboard(:string) :: {:ok, leaderboard} | {:error, String.t()}
  def to_leaderboard(string) do
    if Enum.member?(leaderboards(:string), string) do
      {:ok, String.to_existing_atom(string)}
    else
      {:error, "not valid"}
    end
  end

  @spec to_tour_stop(:string) :: {:ok, tour_stop} | {:error, String.t()}
  def to_tour_stop(string) do
    if Enum.member?(tour_stops(:string), string) do
      {:ok, String.to_existing_atom(string)}
    else
      {:error, "not valid"}
    end
  end

  @spec to_region(:string) :: {:ok, region} | {:error, String.t()}
  def to_region(string) do
    if Enum.member?(regions(:string), string) do
      {:ok, String.to_existing_atom(string)}
    else
      {:error, "not valid"}
    end
  end
end
