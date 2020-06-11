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
          | :Madrid

  @tour_stops [
    :"Las Vegas",
    :Seoul,
    :Bucharest,
    :Arlington,
    :Indonesia,
    :Jönköping,
    :"Asia-Pacific",
    :Montreal,
    :Madrid
  ]
  @battletag_regex ~r/(^([A-zÀ-ú][A-zÀ-ú0-9]{2,11})|(^([а-яёА-ЯЁÀ-ú][а-яёА-ЯЁ0-9À-ú]{2,11})))(#[0-9]{4,})$/

  @type region :: :EU | :US | :AP | :CN
  @regions [:EU, :US, :AP, :CN]
  @qualifier_regions [:EU, :US, :AP]
  @type leaderboard :: :BG | :STD | :WLD
  @leaderboards [:BG, :STD, :WLD]
  # @type battletag :: <<_::binary, "#", _::binary>>
  @type battletag :: String.t()
  @type deckstring :: String.t()
  @typedoc "{year, season}"
  @type gm_season :: {number, number}

  #  @ladder_finish_order [:AP, :EU, :US]

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
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_ladder_tour_stop(season_id) do
    Backend.MastersTour.TourS

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
      82 -> {:ok, :Madrid}
      83 -> {:ok, :Madrid}
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
    case get_ladder_tour_stop(season_id) do
      {:ok, ts} -> ts
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
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
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
      :Madrid -> {:ok, [82, 83]}
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
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
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
      :Madrid -> :EU
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
  @spec get_ladder_priority!(region) :: [region]
  def get_ladder_priority!(region) do
    case region do
      :US -> [:US, :EU, :AP]
      :AP -> [:AP, :US, :EU]
      :EU -> [:EU, :AP, :US]
      _ -> throw("Unknown region")
    end
  end

  # credo:disable-next-line
  # todo Perhaps move to leaderboard module?
  @doc """
  Get the ladders that should be checked when viewing this

  ## Example
    iex> Backend.Blizzard.ladders_to_check(:"Asia-Pacific", :EU)
    [:AP, :US]
  """
  @spec ladders_to_check(tour_stop | integer, region | String.t()) :: [region]
  def ladders_to_check(season_id, region) when is_integer(season_id) do
    ladders_to_check(get_ladder_tour_stop!(season_id), region)
  end

  def ladders_to_check(tour_stop, region) when is_atom(tour_stop) do
    different_region = fn r -> to_string(r) != to_string(region) end

    tour_stop
    |> get_tour_stop_region!()
    |> get_ladder_priority!()
    |> Enum.take_while(different_region)
    |> MapSet.new()
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
  Returns a list of all qualifier eligible regions
  """
  @spec qualifier_regions() :: [region]
  def qualifier_regions() do
    @qualifier_regions
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

  @spec to_region(String.t() | nil) :: {:ok, region} | {:error, String.t()}
  def to_region(nil), do: {:error, "not a string"}

  def to_region(string) do
    if Enum.member?(regions(:string), string) do
      {:ok, String.to_existing_atom(string)}
    else
      {:error, "not valid"}
    end
  end

  @spec is_battletag?(String.t()) :: boolean
  def is_battletag?(string) do
    String.match?(string, @battletag_regex)
  end

  #  def get_money_distribution(tour_stop) do
  #    distribution_unknown = {:error, "Unknown distribution for tour stop"}
  #    case tour_stop do
  #      :LasVegas -> distribution_unknown
  #      :Seoul -> distribution_unknown
  #      :Bucharest -> distribution_unknown
  #      :Arlington -> distribution_unknown
  #      :Indonesia -> distribution_unknown
  #
  #      # edit_hs_decks "5ec9a33da4d7bf2e78ec166a"
  #      :"Jönköping" -> distribution_unknown
  #      :"Asia-Pacific" -> distribution_unknown
  #      :Montreal -> distribution_unknown
  #      :Madrid -> distribution_unknown
  #      _ -> {:error, "Unknown/unsupported tour_stop"}
  #    end
  #  end

  @spec get_tour_stops_for_gm(Blizzard.gm_season()) ::
          {:ok, [Blizzard.tour_stop()]} | {:error, String.t()}
  def get_tour_stops_for_gm(gm_season) do
    case gm_season do
      {2020, 2} -> {:ok, [:Arlington, :Indonesia, :Jönköping]}
      _ -> {:error, "Unknown/unsupported gm_season"}
    end
  end

  @spec get_tour_stops_for_gm!(Blizzard.gm_season()) :: Blizzard.tour_stop()
  def get_tour_stops_for_gm!(gm_season) do
    case get_tour_stops_for_gm(gm_season) do
      {:ok, tour_stops} -> tour_stops
      {:error, error} -> raise error
    end
  end

  @spec qualifier_regions_with_name() :: [{region(), String.t()}]
  def qualifier_regions_with_name() do
    qualifier_regions_with_name(:long)
  end

  @spec qualifier_regions_with_name(:long | :short) :: [{region(), String.t()}]
  def qualifier_regions_with_name(:long) do
    qualifier_regions() |> Enum.map(fn r -> {r, get_region_name(r, :long)} end)
  end

  @spec qualifier_regions_with_name(:long | :short) :: [{region(), String.t()}]
  def qualifier_regions_with_name(:short) do
    qualifier_regions() |> Enum.map(fn r -> {r, get_region_name(r, :short)} end)
  end

  @spec get_region_name(String.t() | region()) :: String.t()
  def get_region_name(region) do
    get_region_name(region, :long)
  end

  @spec get_region_name(region() | String.t(), :long | :short) :: String.t()
  def get_region_name(region, :long) when is_atom(region) do
    case region do
      :EU -> "Europe"
      :US -> "Americas"
      :AP -> "Asia-Pacific"
      :CN -> "China"
    end
  end

  @spec get_region_name(region(), :long | :short) :: String.t()
  def get_region_name(region, :short) when is_atom(region) do
    case region do
      :EU -> "EU"
      :US -> "AM"
      :AP -> "AP"
      :CN -> "CN"
    end
  end

  def get_region_name(region, length) when is_binary(region) do
    get_region_name(String.to_existing_atom(region), length)
  end

  @spec leaderboards_with_name() :: [{leaderboard(), String.t()}]
  def leaderboards_with_name() do
    leaderboards_with_name(:long)
  end

  @spec leaderboards_with_name(:short | :long) :: [{leaderboard(), String.t()}]
  def leaderboards_with_name(length) do
    leaderboards() |> Enum.map(fn l -> {l, get_leaderboard_name(l, length)} end)
  end

  @spec get_leaderboard_name(String.t() | leaderboard()) :: String.t()
  def get_leaderboard_name(leaderboard) do
    get_leaderboard_name(leaderboard, :long)
  end

  @spec get_leaderboard_name(String.t() | leaderboard()) :: String.t()
  def get_leaderboard_name(leaderboard, :long) when is_atom(leaderboard) do
    case leaderboard do
      :BG -> "Battlegrounds"
      :STD -> "Standard"
      :WLD -> "Wild"
    end
  end

  @spec get_leaderboard_name(String.t() | leaderboard(), :short | :long) :: String.t()
  def get_leaderboard_name(leaderboard, :short) when is_atom(leaderboard) do
    case leaderboard do
      :BG -> "BG"
      :STD -> "STD"
      :WLD -> "WLD"
    end
  end

  def get_leaderboard_name(leaderboard, length) when is_binary(leaderboard) do
    get_leaderboard_name(String.to_existing_atom(leaderboard), length)
  end

  @spec get_tour_stops_for_year(integer) :: [tour_stop()]
  def get_tour_stops_for_year(year) do
    case year do
      2020 -> [:Arlington, :Indonesia, :Jönköping, :"Asia-Pacific", :Montreal, :Madrid]
      2019 -> [:"Las Vegas", :Seoul, :Bucharest]
      _ -> []
    end
  end

  @spec get_year_for_tour_stop(tour_stop()) :: integer
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_year_for_tour_stop(tour_stop) do
    case tour_stop do
      :LasVegas -> 2019
      :Seoul -> 2019
      :Bucharest -> 2019
      :Arlington -> 2020
      :Indonesia -> 2020
      :Jönköping -> 2020
      :"Asia-Pacific" -> 2020
      :Montreal -> 2020
      :Madrid -> 2020
      _ -> {:error, "Unknown tour stop #{tour_stop}"}
    end
  end
end
