defmodule Backend.Blizzard do
  @moduledoc false

  require Backend.LobbyLegends
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
          | :"Masters Tour One"
          | :"Masters Tour Two"
          | :"Masters Tour Three"
          | :"Masters Tour Four"
          | :"Masters Tour Five"
          | :"Masters Tour Six"

  @battletag_regex ~r/(^([A-zÀ-ú][A-zÀ-ú0-9]{2,11})|(^([а-яёА-ЯЁÀ-ú][а-яёА-ЯЁ0-9À-ú]{2,11})))(#[0-9]{4,})$/
  @short_battletag_regex ~r/(^([A-zÀ-ú][A-zÀ-ú0-9]{2,11})|(^([а-яёА-ЯЁÀ-ú][а-яёА-ЯЁ0-9À-ú]{2,11})))$/
  @current_bg_season_id 13
  # guess, change if not correct
  @current_bg_season_end_date ~N[2024-12-03 18:00:00]
  @current_arena_season_id 51
  # guess, change if not correct
  @current_arena_season_end_date ~N[2024-12-03 18:00:00]

  defmacro is_old_bg_season(season_id) do
    quote do
      unquote(season_id) < unquote(@current_bg_season_id)
    end
  end

  defmacro is_unrealistic_bg_season(season_id) do
    quote do
      unquote(season_id) > unquote(@current_bg_season_id) + 1
    end
  end

  @type region :: :EU | :US | :AP | :CN
  @regions [:EU, :US, :AP, :CN]
  @qualifier_regions [:EU, :US, :AP]
  @type leaderboard :: :BG | :STD | :WLD | :CLS | :MRC | :arena | :twist | :DUO
  @leaderboards [:BG, :DUO, :STD, :WLD, :CLS, :MRC, :arena, :twist]
  @defunct_leaderboards [:CLS]
  # @type battletag :: <<_::binary, "#", _::binary>>
  @type battletag :: String.t()
  @type deckstring :: String.t()
  @typedoc "{year, season}"
  @type gm_season :: {number, number}

  @type leaderboard_id :: leaderboard | String.t()

  @spec season_id_def(leaderboard_id()) :: {start_year :: integer(), month_offset :: integer()}
  def season_id_def(ldb) when ldb in [:MRC, "MRC"] do
    {2021, 10}
  end

  def season_id_def(_) do
    {2013, 10}
  end

  @spec get_month_start(integer) :: Date.t()
  def get_month_start(season_id), do: get_month_start(season_id, :STD)

  @doc """
  Gets the year and month from a season_id

  ## Example
    iex> Backend.Blizzard.get_month_start(75, :STD)
    ~D[2020-01-01]
    iex> Backend.Blizzard.get_month_start(74, "WLD")
    ~D[2019-12-01]
    iex> Backend.Blizzard.get_month_start(2, :MRC)
    ~D[2021-12-01]
    iex> Backend.Blizzard.get_month_start(3, :MRC)
    ~D[2022-01-01]
  """
  @spec get_month_start(integer(), leaderboard_id()) :: Date.t()
  def get_month_start(season_id, ldb) do
    {start_year, month_offset} = season_id_def(ldb)
    month = Util.normalize_month(rem(season_id + month_offset, 12))
    year = start_year + div(season_id - month + month_offset, 12)

    case Date.new(year, month, 1) do
      {:ok, date} -> date
      # this should never happen
      {:error, reason} -> throw(reason)
    end
  end

  @spec get_season_id(Calendar.date() | %{month: number, year: number}) :: number
  def get_season_id(date), do: get_season_id(date, :STD)

  @doc """
  Gets the season id for a date

  ## Example
    iex> Backend.Blizzard.get_season_id(~D[2019-12-01], :WLD)
    74
    iex> Backend.Blizzard.get_season_id(~D[2020-01-31], "STD")
    75
    iex> Backend.Blizzard.get_season_id(~D[2022-01-04], :MRC)
    3
  """
  @spec get_season_id(Calendar.date(), leaderboard) :: number()
  def get_season_id(date, ldb) do
    {year_start, month_offset} = season_id_def(ldb)
    (date.year - year_start) * 12 + date.month - month_offset
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
  def get_ladder_priority!(ts) when ts != nil and (is_atom(ts) or is_binary(ts)),
    do: ts |> TourStop.get() |> get_ladder_priority!()

  def get_ladder_priority!(%{ladder_priority: :regional, region: region}) do
    case region do
      :US -> [:US, :EU, :AP]
      :AP -> [:AP, :US, :EU]
      :EU -> [:EU, :AP, :US]
      _ -> throw("Unknown region")
    end
  end

  @timezone_order [:AP, :EU, :US]
  def get_ladder_priority!(%{ladder_priority: :timezone}), do: @timezone_order
  def get_ladder_priority!(%{ladder_priority: nil}), do: []
  def get_ladder_priority!(_), do: throw("Unsupported tour stop")

  # credo:disable-next-line
  # todo Perhaps move to leaderboard module?
  @doc """
  Get the ladders that should be checked when viewing this

  ## Example
    iex> Backend.Blizzard.ladders_to_check(99, :STD, :EU)
    [:AP]
    iex> Backend.Blizzard.ladders_to_check(5, :BG, :US)
    [:AP, :EU]
    iex> Backend.Blizzard.ladders_to_check(100, :STD, :AP)
    []
  """
  @spec ladders_to_check(integer, leaderboard | String.t(), region | String.t()) :: [region]
  def ladders_to_check(season_id, ldb, region)
      when is_integer(season_id) and ldb in ["STD", :STD] do
    case get_ladder_tour_stop(season_id) do
      {:ok, tour_stop} -> ladders_to_check(tour_stop, region)
      {:error, _} -> []
    end
  end

  def ladders_to_check(s, ldb, region)
      when ldb in ["BG", :BG] and Backend.LobbyLegends.is_lobby_legends(s),
      do: skip_current(@timezone_order, region)

  def ladders_to_check(_, ldb, _) when ldb in ["BG", :BG], do: []

  # credo:disable-next-line
  # todo Perhaps move to leaderboard module?
  @doc """
  Get the ladders that should be checked when viewing this

  ## Example
    iex> Backend.Blizzard.ladders_to_check(:"Asia-Pacific", :EU)
    [:AP, :US]
  """
  @spec ladders_to_check(tour_stop | atom, region | String.t()) :: [region]
  def ladders_to_check(tour_stop, region) when is_atom(tour_stop) do
    tour_stop
    |> get_ladder_priority!()
    |> skip_current(region)
  end

  defp skip_current(regions, current) do
    Enum.take_while(regions, &(to_string(&1) != to_string(current)))
    |> Enum.uniq()
  end

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
  Returns a list of all active leaderboards
  Doesn't include modes that are now dead
  """
  @spec active_leaderboards() :: [leaderboard]
  def active_leaderboards() do
    leaderboards()
    |> Enum.reject(&(&1 in @defunct_leaderboards))
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

  @spec battletag?(String.t()) :: boolean
  def battletag?(string) do
    String.match?(string, @battletag_regex)
  end

  @spec short_battletag?(String.t()) :: boolean
  def short_battletag?(string) do
    String.match?(string, @short_battletag_regex)
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

      {2022, 2} ->
        {:ok,
         [
           :Silvermoon,
           :Stormwind,
           :Undercity,
           :"Masters Tour One",
           :"Masters Tour Two",
           :"Masters Tour Three"
         ]}

      {2022, :summer} ->
        {:ok, [:"Masters Tour One", :"Masters Tour Two", :"Masters Tour Three"]}

      {2022, :fall} ->
        {:ok, [:"Masters Tour Four", :"Masters Tour Five", :"Masters Tour Six"]}

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
      :"Masters Tour One" -> {:ok, {2022, 2}}
      :"Masters Tour Two" -> {:ok, {2022, 2}}
      :"Masters Tour Three" -> {:ok, {2022, 2}}
      # todo see if this is needed, there
      :"Masters Tour Four" -> {:ok, {2023, 1}}
      :"Masters Tour Five" -> {:ok, {2023, 1}}
      :"Masters Tour Six" -> {:ok, {2023, 1}}
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

  @spec get_region_identifier(atom() | String.t() | %{region: String.t() | atom()}) ::
          {:ok, atom()} | {:error, any()}
  def get_region_identifier(%{region: r}), do: get_region_identifier(r)
  def get_region_identifier(r) when r in [:EU, :US, :AP, :CN], do: {:ok, r}
  def get_region_identifier(r) when r in ["EU", "Europe"], do: {:ok, :EU}
  def get_region_identifier(r) when r in ["AM", "NA", "Americas", :NA], do: {:ok, :US}

  def get_region_identifier(r) when r in ["AP", "APAC", "Asia-Pacific", :APAC, "Asia"],
    do: {:ok, :AP}

  def get_region_identifier(r) when r in ["CN", "China"], do: {:ok, :CN}
  def get_region_identifier(r), do: {:error, "unknown_region #{r}"}

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

  @spec get_leaderboard_name(String.t() | leaderboard(), :short | :long) :: String.t()
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_leaderboard_name(leaderboard, :long) when is_atom(leaderboard) do
    case leaderboard do
      :BG_LL -> "BGs LL/Monthly"
      :BG -> "Battlegrounds"
      :STD -> "Standard"
      :WLD -> "Wild"
      :CLS -> "Classic"
      :MRC -> "Mercenaries"
      :twist -> "Twist"
      :arena -> "Arena"
      :DUO -> "Battlegrounds Duos"
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_leaderboard_name(leaderboard, :short) when is_atom(leaderboard) do
    case leaderboard do
      :BG_LL -> "BG_LL"
      :BG -> "BG"
      :STD -> "STD"
      :WLD -> "WLD"
      :CLS -> "CLS"
      :MRC -> "MRC"
      :arena -> "arena"
      :twist -> "twist"
      :DUO -> "Duos"
    end
  end

  def get_leaderboard_name("BG_LL", length), do: get_leaderboard_name(:BG_LL, length)

  def get_leaderboard_name(leaderboard, length) when is_binary(leaderboard) do
    @leaderboards
    |> Enum.find(&(to_string(&1) == leaderboard))
    |> case do
      nil -> ""
      ldb -> get_leaderboard_name(ldb, length)
    end
  end

  @spec get_leaderboard_name(region(), leaderboard(), integer, :short | :long) :: String.t()
  def get_leaderboard_name(region, leaderboard, season_id, length \\ :long)

  def get_leaderboard_name(region, ldb, season_id, length) when ldb in [:arena, :BG, :DUO] do
    r = get_region_name(region, length)
    leaderboard = get_leaderboard_name(ldb, length)
    "#{leaderboard} #{r} #{get_season_name(season_id, ldb)}"
  end

  for ldb <- [:BG, :MRC, :arena, :DUO] do
    def get_leaderboard_name(region, unquote(to_string(ldb)), season_id, length),
      do: get_leaderboard_name(region, unquote(ldb), season_id, length)
  end

  def get_leaderboard_name(region, leaderboard, season_id, length) do
    %{year: year, month: month} = get_month_start(season_id, leaderboard)
    m = Util.get_month_name(month)
    r = get_region_name(region, length)
    ldb = get_leaderboard_name(leaderboard, length)
    "#{ldb} #{r} #{m} #{year}"
  end

  @spec get_leaderboard(region(), leaderboard(), integer | nil) :: Leaderboard
  def get_leaderboard(region, leaderboard, season_id) do
    # todo pick season_id when nil
    Api.get_leaderboard(region, leaderboard, season_id)
  end

  @spec get_tour_stops_for_year(integer) :: [tour_stop()]
  def get_tour_stops_for_year(year) do
    TourStop.all()
    |> Enum.filter(&(&1.year == year))
    |> Enum.map(& &1.id)
  end

  def get_season_name(season, "DUO"), do: get_season_name(season, :DUO)
  def get_season_name(season, "BG"), do: get_season_name(season, :BG)
  def get_season_name(season, ldb) when ldb in [:BG, :DUO], do: "Season #{season + 1}"
  def get_season_name(season, ldb) when ldb in [:arena, "arena"], do: "Season #{season}"

  def get_ineligible_players() do
    [
      %{battletag_short: "Archangel", from: ~D[2019-01-01]},
      %{battletag_short: "Chakki", from: ~D[2019-01-01]},
      %{battletag_short: "Gallon", from: ~D[2020-08-01]},
      %{battletag_short: "BoarControl", from: ~D[2020-10-01]},
      %{battletag_short: "RHat", from: ~D[2023-05-08]}
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

  def ineligible?(_, nil), do: false

  @spec get_single_gm_lineup(String.t(), String.t()) :: Hearthstone.Lineup.t() | nil
  def get_single_gm_lineup(stage_title, gm),
    do: current_gm_season() |> get_single_gm_lineup(stage_title, gm)

  @spec get_single_gm_lineup(String.t(), String.t(), String.t()) :: Hearthstone.Lineup.t() | nil
  def get_single_gm_lineup(season, stage_title, gm) do
    get_grandmasters_lineups(season, stage_title)
    |> Enum.find(&(&1.name == gm))
  end

  def gm_tournament_title(season), do: "gm_#{gm_season_string(season)}"

  def gm_lineup_tournament_id(gm_season, stage_title),
    do: "#{gm_tournament_title(gm_season)}_#{stage_title}"

  def get_grandmasters_lineups(gm_season, stage_title) do
    tournament = gm_lineup_tournament_id(gm_season, stage_title)

    Hearthstone.lineups([{"tournament_id", tournament}, {"tournament_source", "grandmasters"}])
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

  def current_gm_season(), do: {2022, 2}

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

  def playin_weeks({2022, 1}), do: 3
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
    do: break_weeks |> Enum.count(&(&1 <= week))

  def weeks_so_far(season_def = %{break_weeks: break_weeks, playoffs_week: playoffs}) do
    week_range(season_def)
    |> Enum.filter(&(!(&1 in break_weeks) && &1 <= playoffs))
    |> Enum.map(&gm_week(season_def, &1))
  end

  def weeks_so_far(season), do: season |> gm_season_definition() |> weeks_so_far()

  def week_range(%{week_one: week_one}) do
    {_year, current} = Util.current_week()

    if week_one > current do
      []
    else
      week_one..current
    end
  end

  @spec gm_season_definition({integer(), integer()}) :: %{
          break_weeks: [integer()],
          playoffs_week: integer(),
          week_one: integer()
        }
  def gm_season_definition({2022, 2}),
    do: %{week_one: 29, playoffs_week: 33, break_weeks: [31, 32]}

  def gm_season_definition({2022, 1}), do: %{week_one: 8, playoffs_week: 12, break_weeks: [11]}
  def gm_season_definition({2021, 1}), do: %{week_one: 14, playoffs_week: 22, break_weeks: [17]}
  def gm_season_definition({2021, 2}), do: %{week_one: 32, playoffs_week: 40, break_weeks: [35]}

  def get_current_ladder_season(ldb) when ldb in [:arena, "arena"] do
    now = NaiveDateTime.utc_now()

    if :lt == NaiveDateTime.compare(now, @current_arena_season_end_date) do
      @current_arena_season_id
    else
      @current_arena_season_id + 1
    end
  end

  def get_current_ladder_season(ldb) when ldb in [:BG, "BG", :DUO, "DUO"] do
    now = NaiveDateTime.utc_now()

    if :lt == NaiveDateTime.compare(now, @current_bg_season_end_date) do
      @current_bg_season_id
    else
      @current_bg_season_id + 1
    end
  end

  def get_current_ladder_season(ldb), do: get_season_id(Date.utc_today(), ldb)

  @spec get_current_ladder_season(leaderboard_id :: leaderboard(), region :: region()) ::
          integer()
  def get_current_ladder_season(ldb, _region) when ldb in [:arena, :BG, :DUO] do
    get_current_ladder_season(ldb)
  end

  def get_current_ladder_season(ldb, region) do
    timezone = regions_with_timezone() |> Keyword.get(region)
    one_hour_ago = Timex.now(timezone) |> Timex.shift(hours: -1)
    date = Timex.to_date(one_hour_ago)
    get_season_id(date, ldb)
  end

  @spec regions_with_timezone :: [{leaderboard(), String.t()}]
  def regions_with_timezone(),
    do: [{:US, "US/Pacific"}, {:AP, "Asia/Seoul"}, {:EU, "CET"}, {:CN, "Asia/Shanghai"}]
end
