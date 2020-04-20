defmodule Backend.Blizzard do
  @moduledoc false
  @type tour_stop ::
          :"Las Vegas"
          | :Seoul
          | :Bucharest
          | :Arlington
          | :Indonesia
          | :Jönköping
          | :"Asia-Pacific"
          | :Montreal

  @tour_stops [
    :"Las Vegas",
    :Seoul,
    :Bucharest,
    :Arlington,
    :Indonesia,
    :Jönköping,
    :"Asia-Pacific",
    :Montreal
  ]

  @type region :: :EU | :US | :AP
  @regions [:EU, :US, :AP]
  @type leaderboard :: :BG | :STD | :WLD
  @leaderboards [:BG, :STD, :WLD]
  # @type battletag :: <<_::binary, "#", _::binary>>
  @type battletag :: String.t()
  @type deckstring :: String.t()

  @ladder_finish_order [:AP, :EU, :US]

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
    {:ok, :"Asia-Pacific"}
  """
  @spec get_ladder_tour_stop(integer()) :: {:ok, tour_stop} | {:error, String.t()}
  # credo:disable-for-this-file
  def get_ladder_tour_stop(season_id) do
    case season_id do
      72 -> {:ok, :Arlington}
      73 -> {:ok, :Arlington}
      74 -> {:ok, :Indonesia}
      75 -> {:ok, :Indonesia}
      76 -> {:ok, :Jönköping}
      77 -> {:ok, :Jönköping}
      78 -> {:ok, :"Asia-Pacific"}
      79 -> {:ok, :"Asia-Pacific"}
      80 -> {:ok, :Montreal}
      81 -> {:ok, :Montreal}
      _ -> {:error, "Invalid tour stop for ladder"}
    end
  end

  @doc """
  Gets the tour stop a ladder season qualifies for

  ## Example
    iex> Backend.Blizzard.get_ladder_tour_stop!(72)
    :Arlington
    iex> Backend.Blizzard.get_ladder_tour_stop!(79)
    :"Asia-Pacific"
  """
  @spec get_ladder_tour_stop(integer()) :: tour_stop
  def get_ladder_tour_stop!(season_id) do
    with {:ok, ts} <- get_ladder_tour_stop(season_id) do
      ts
    else
      {:error, reason} -> throw(reason)
    end
  end

  @doc """
  Gets the season ids of ladder qualifying seasons for a tour stop

  ## Example
    iex> Backend.Blizzard.get_ladder_seasons(:"Asia-Pacific")
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
      :"Asia-Pacific" -> {:ok, [78, 79]}
      :Montreal -> {:ok, [80, 81]}
      _ -> {:error, "Unknown tour stop #{tour_stop}"}
    end
  end

  @doc """
  Gets the region of the tour stop

  ## Example
    iex> Backend.Blizzard.get_tour_stop_region!(:"Asia-Pacific")
    :AP
    iex> Backend.Blizzard.get_tour_stop_region!(:Montreal)
    :US
  """
  @spec get_tour_stop_region!(tour_stop) :: region
  def get_tour_stop_region!(tour_stop) do
    case tour_stop do
      :LasVegas -> :US
      :Seoul -> :AP
      :Bucharest -> :EU
      :Arlington -> :US
      :Indonesia -> :AP
      :Jönköping -> :EU
      :"Asia-Pacific" -> :AP
      :Montreal -> :US
      _ -> throw("Unknown tour stop")
    end
  end

  @doc """
  Gets the region of the tour stop

  ## Example
    iex> Backend.Blizzard.get_tour_stop_region!(:"Asia-Pacific")
    :AP
    iex> Backend.Blizzard.get_tour_stop_region!(:Montreal)
    :US
  """
  @spec get_tour_stop_region!(region) :: [region]
  def get_ladder_priority!(region) do
    case region do
      :US -> [:US, :EU, :AP]
      :AP -> [:AP, :US, :EU]
      :EU -> [:EU, :AP, :US]
      _ -> throw("Unknown region")
    end
  end

  # todo Perhaps move to leaderboard module?
  @doc """
  Get the ladders that should be checked when viewing this

  ## Example
    iex> Backend.Blizzard.ladders_to_check(:"Asia-Pacific", :EU)
    [:AP]
  """
  @spec ladders_to_check(tour_stop | integer, region | String.t()) :: [region]
  def ladders_to_check(season_id, region) when is_integer(season_id) do
    ladders_to_check(get_ladder_tour_stop!(season_id), region)
  end

  def ladders_to_check(tour_stop, region) when is_atom(tour_stop) do
    different_region = fn r -> to_string(r) != to_string(region) end
    regions_ahead = @ladder_finish_order |> Enum.take_while(different_region) |> MapSet.new()

    tour_stop
    |> get_tour_stop_region!()
    |> get_ladder_priority!()
    |> Enum.take_while(different_region)
    |> MapSet.new()
    |> MapSet.intersection(regions_ahead)
    |> MapSet.to_list()
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

  @spec to_region(String.t()) :: {:ok, region} | {:error, String.t()}
  def to_region(string) do
    if Enum.member?(regions(:string), string) do
      {:ok, String.to_existing_atom(string)}
    else
      {:error, "not valid"}
    end
  end
end
