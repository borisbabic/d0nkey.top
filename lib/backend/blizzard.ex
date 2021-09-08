defmodule Backend.Blizzard do
  @moduledoc false

  alias Backend.Infrastructure.BlizzardCommunicator, as: Api
  alias Backend.Blizzard.Leaderboard
  alias Backend.Hearthstone
  alias Backend.MastersTour.TourStop

  @type tour_stop ::
          :"Las Vegas"
          | :Seoul
          | :Bucharest
          | :Arlington
          | :Indonesia
          | :Jönköping
          | :"Asia-Pacific"
          | :Montréal
          | :Madrid
          | :Ironforge
          | :Orgrimmar
          | :Dalaran
          | :Silvermoon
          | :Stormwind
          | :Undercity

  @battletag_regex ~r/(^([A-zÀ-ú][A-zÀ-ú0-9]{2,11})|(^([а-яёА-ЯЁÀ-ú][а-яёА-ЯЁ0-9À-ú]{2,11})))(#[0-9]{4,})$/
  @current_bg_season_id 4

  defmacro is_old_bg_season(season_id) do
    quote do
      unquote(season_id) < unquote(@current_bg_season_id)
    end
  end

  @type region :: :EU | :US | :AP | :CN
  @regions [:EU, :US, :AP, :CN]
  @qualifier_regions [:EU, :US, :AP]
  @type leaderboard :: :BG | :STD | :WLD | :CLS
  @leaderboards [:BG, :STD, :WLD, :CLS]
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
    TourStop.get_by_ladder(season_id)
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

    tour_stop
    |> TourStop.get()
    |> case do
      %{ladder_seasons: []} -> no_ladder_for_tour
      %{ladder_seasons: seasons} -> {:ok, seasons}
      _ -> {:error, "Unknown tour stop #{tour_stop}"}
    end
  end

  @doc """
  Gets the region of the tour stop

  ## Example
    iex> Backend.Blizzard.get_tour_stop_region!(:"Asia-Pacific")
    :AP
    iex> Backend.Blizzard.get_tour_stop_region!(:"Montréal")
    :US
  """
  @spec get_tour_stop_region!(tour_stop) :: region
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_tour_stop_region!(tour_stop) do
    tour_stop
    |> TourStop.get()
    |> case do
      %{region: region} -> region
      _ -> throw("Unknown tour stop")
    end
  end

  @doc """
  Gets the region of the tour stop

  ## Example
    iex> Backend.Blizzard.get_tour_stop_region!(:"Asia-Pacific")
    :AP
    iex> Backend.Blizzard.get_tour_stop_region!(:"Montréal")
    :US
  """
  @spec get_ladder_priority!(tour_stop | TourStop.t()) :: [region]
  def get_ladder_priority!(ts) when is_atom(ts) or is_binary(ts),
    do: ts |> TourStop.get() |> get_ladder_priority!()

  def get_ladder_priority!(%{ladder_priority: :regional, region: region}) do
    case region do
      :US -> [:US, :EU, :AP]
      :AP -> [:AP, :US, :EU]
      :EU -> [:EU, :AP, :US]
      _ -> throw("Unknown region")
    end
  end

  def get_ladder_priority!(%{ladder_priority: :timezone}), do: [:AP, :EU, :US]
  def get_ladder_priority!(_), do: throw("Unsupported tour stop")

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
    case get_ladder_tour_stop(season_id) do
      {:ok, tour_stop} -> ladders_to_check(tour_stop, region)
      {:error, _} -> []
    end
  end

  def ladders_to_check(tour_stop, region) when is_atom(tour_stop) do
    different_region = fn r -> to_string(r) != to_string(region) end

    tour_stop
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
    TourStop.all() |> Enum.map(& &1.id)
  end

  @doc """
  Returns a list of all tour stops as strings
  """
  @spec tour_stops(:string) :: [String.t()]
  def tour_stops(:string) do
    tour_stops() |> Enum.map(&to_string/1)
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
  #      :"Montréal" -> distribution_unknown
  #      :Madrid -> distribution_unknown
  #      _ -> {:error, "Unknown/unsupported tour_stop"}
  #    end
  #  end

  @spec get_tour_stops_for_gm(Blizzard.gm_season()) ::
          {:ok, [Blizzard.tour_stop()]} | {:error, String.t()}
  def get_tour_stops_for_gm(gm_season) do
    case gm_season do
      {2020, 2} ->
        {:ok, [:Arlington, :Indonesia, :Jönköping]}

      {2021, 1} ->
        {:ok, [:Arlington, :Indonesia, :Jönköping, :"Asia-Pacific", :Montréal, :Madrid]}

      {2021, 2} ->
        {:ok, [:"Asia-Pacific", :Montréal, :Madrid, :Ironforge, :Orgrimmar, :Dalaran]}

      {2022, 1} ->
        {:ok, [:Ironforge, :Orgrimmar, :Dalaran, :Silvermoon, :Stormwind, :Undercity]}

      _ ->
        {:error, "Unknown/unsupported gm_season"}
    end
  end

  @spec get_promotion_season_for_gm(tour_stop()) :: {:ok, gm_season()} | {:error, String.t()}
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_promotion_season_for_gm(tour_stop) do
    case tour_stop do
      :LasVegas -> {:ok, {2020, 1}}
      :Seoul -> {:ok, {2020, 1}}
      :Bucharest -> {:ok, {2020, 1}}
      :Arlington -> {:ok, {2020, 2}}
      :Indonesia -> {:ok, {2020, 2}}
      :Jönköping -> {:ok, {2020, 2}}
      :"Asia-Pacific" -> {:ok, {2021, 1}}
      :Montréal -> {:ok, {2021, 1}}
      :Madrid -> {:ok, {2021, 1}}
      :Ironforge -> {:ok, {2021, 2}}
      :Orgrimmar -> {:ok, {2021, 2}}
      :Dalaran -> {:ok, {2021, 2}}
      :Silvermoon -> {:ok, {2022, 1}}
      :Stormwind -> {:ok, {2022, 1}}
      :Undercity -> {:ok, {2022, 1}}
      _ -> {:error, "Unknown tour stop #{tour_stop}"}
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
      :CLS -> "Classic"
    end
  end

  @spec get_leaderboard_name(String.t() | leaderboard(), :short | :long) :: String.t()
  def get_leaderboard_name(leaderboard, :short) when is_atom(leaderboard) do
    case leaderboard do
      :BG -> "BG"
      :STD -> "STD"
      :WLD -> "WLD"
      :CLS -> "CLS"
    end
  end

  def get_leaderboard_name(leaderboard, length) when is_binary(leaderboard) do
    @leaderboards
    |> Enum.find(&(to_string(&1) == leaderboard))
    |> case do
      nil -> ""
      ldb -> get_leaderboard_name(ldb, length)
    end
  end

  @spec get_tour_stops_for_year(integer) :: [tour_stop()]
  def get_tour_stops_for_year(year) do
    TourStop.all()
    |> Enum.filter(&(&1.year == year))
    |> Enum.map(& &1.id)
  end

  @spec get_leaderboard(region(), leaderboard(), integer | nil) :: Leaderboard
  def get_leaderboard(region, leaderboard, season_id) do
    # todo pick season_id when nil
    Api.get_leaderboard(region, leaderboard, season_id)
  end

  @spec get_leaderboard_name(region(), leaderboard(), integer, :short | :long) :: Leaderboard
  def get_leaderboard_name(region, leaderboard, season_id, length \\ :long)

  def get_leaderboard_name(region, "BG", season_id, length),
    do: get_leaderboard_name(region, :BG, season_id, length)

  def get_leaderboard_name(region, :BG, season_id, length) do
    r = get_region_name(region, length)
    ldb = get_leaderboard_name(:BG, length)
    "#{ldb} #{r} #{get_season_name(season_id, :BG)}"
  end

  def get_season_name(season, "BG"), do: get_season_name(season, :BG)
  def get_season_name(season, :BG), do: "Season #{season + 1}"

  def get_leaderboard_name(region, leaderboard, season_id, length) do
    %{year: year, month: month} = get_month_start(season_id)
    m = Util.get_month_name(month)
    r = get_region_name(region, length)
    ldb = get_leaderboard_name(leaderboard, length)
    "#{ldb} #{r} #{m} #{year}"
  end

  def get_ineligible_players() do
    [
      %{battletag_short: "Archangel", from: ~D[2019-01-01]},
      %{battletag_short: "Chakki", from: ~D[2019-01-01]},
      %{battletag_short: "Gallon", from: ~D[2020-08-01]},
      %{battletag_short: "BoarControl", from: ~D[2020-10-01]}
    ]
  end

  def ineligible?(battletag_short, %{year: year, month: month, day: day}) do
    Date.new(year, month, day)
    |> case do
      {:ok, date} ->
        get_ineligible_players()
        |> Enum.any?(fn %{battletag_short: bt, from: d} ->
          battletag_short == bt && Date.compare(d, date) == :lt
        end)

      _ ->
        false
    end
  end

  @spec get_single_gm_lineup(String.t(), String.t()) :: Hearthstone.Lineup.t() | nil
  def get_single_gm_lineup(stage_title, gm),
    do: current_gm_season() |> get_single_gm_lineup(stage_title, gm)

  @spec get_single_gm_lineup(String.t(), String.t(), String.t()) :: Hearthstone.Lineup.t() | nil
  def get_single_gm_lineup(season, stage_title, gm) do
    get_grandmasters_lineups(season, stage_title)
    |> Enum.find(&(&1.name == gm))
  end

  def ineligible?(_, nil), do: false

  def gm_tournament_title(season), do: "gm_#{gm_season_string(season)}"

  def gm_lineup_tournament_id(gm_season, stage_title),
    do: "#{gm_tournament_title(gm_season)}_#{stage_title}"

  def get_grandmasters_lineups(gm_season, stage_title) do
    tournament = gm_lineup_tournament_id(gm_season, stage_title)

    Hearthstone.get_lineups(tournament, "grandmasters")
    |> case do
      lineups = [_ | _] ->
        lineups

      _ ->
        Backend.Grandmasters.LineupFetcher.enqueue_job(stage_title)
        []
    end
  end

  def get_grandmasters_lineups(stage_title) do
    gm_season = current_gm_season()
    get_grandmasters_lineups(gm_season, stage_title)
  end

  def get_grandmasters_lineups(),
    do: current_or_default_week_title() |> get_grandmasters_lineups()

  def current_gm_season(), do: {2021, 2}

  def current_or_default_week_title(), do: current_gm_season() |> current_or_default_week_title()

  def current_or_default_week_title(season) do
    season
    |> current_gm_week_title()
    |> or_default_week_title()
  end

  def or_default_week_title({:ok, title}), do: title
  def or_default_week_title(_), do: "Playoffs"

  def gm_season_string({year, num}), do: "#{year}_#{num}"

  def current_gm_week_title(season) when is_binary(season),
    do: season |> Hearthstone.parse_gm_season!() |> current_gm_week_title()

  def current_gm_week_title(season) when is_tuple(season) do
    with {_, week_num} <- season |> current_gm_week() do
      gm_week_title(season, week_num)
    end
  end

  def gm_week_title(season, week_num) do
    playin = playin_weeks(season)

    cond do
      0 < week_num && week_num <= playin -> {:ok, "Week #{week_num}"}
      week_num == playin + 1 -> {:ok, "Playoffs"}
      true -> :error
    end
  end

  def playin_weeks(_), do: 7

  def current_gm_week(season),
    do: season |> gm_season_definition() |> gm_week(Util.current_week())

  def gm_week(season_def, {_year, week_num}), do: gm_week(season_def, week_num)

  def gm_week(%{week_one: week_one, playoffs_week: playoffs, break_weeks: break_weeks}, week) do
    week
    |> case do
      week when week >= week_one and week < playoffs ->
        {:playin, week - week_one + 1 - break_weeks_so_far(week, break_weeks)}

      ^playoffs ->
        {:playoffs, playoffs - week_one + 1 - break_weeks_so_far(playoffs, break_weeks)}

      # keep different size than the above
      _ ->
        :error
    end
  end

  defp break_weeks_so_far(week, break_weeks),
    do: break_weeks |> Enum.filter(&(&1 <= week)) |> Enum.count()

  def weeks_so_far(
        season_def = %{week_one: week_one, break_weeks: break_weeks, playoffs_week: playoffs}
      ) do
    {_year, current} = Util.current_week()

    week_one..current
    |> Enum.filter(&(!(&1 in break_weeks) && &1 <= playoffs))
    |> Enum.map(&gm_week(season_def, &1))
  end

  def weeks_so_far(season), do: season |> gm_season_definition() |> weeks_so_far()

  def gm_season_definition({2021, 1}), do: %{week_one: 14, playoffs_week: 22, break_weeks: [17]}
  def gm_season_definition({2021, 2}), do: %{week_one: 32, playoffs_week: 40, break_weeks: [35]}

  def get_current_ladder_season("BG"), do: get_current_ladder_season(:BG)
  def get_current_ladder_season(:BG), do: @current_bg_season_id
  def get_current_ladder_season(_ldb), do: get_season_id(Date.utc_today())
end
