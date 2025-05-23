defmodule Backend.PlayerInfo do
  @moduledoc false
  alias Backend.Blizzard
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.PrioritizedBattletagCache
  @type country_code :: <<_::2>>
  @type player_info :: %{region: Blizzard.region() | nil, country: country_code | nil}

  def relegated_gms_for_promotion({2020, 2}) do
    MapSet.new([
      "Kolento",
      "Pavel",
      "hunterace",
      "Purple",
      "PNC",
      "PapaJason",
      "SamuelTsao",
      "Staz",
      "FroStee"
    ])
  end

  def relegated_gms_for_promotion({2021, 1}) do
    MapSet.new([
      "Ryvius",
      "kin0531",
      "SilverName",
      "BoarControl",
      "Justsaiyan",
      "justsaiyan",
      "Warma",
      "Flurry",
      "Firebat",
      "Empanizado"
    ])
    |> MapSet.union(relegated_gms_for_promotion({2020, 2}))
  end

  def relegated_gms_for_promotion({2021, 2}) do
    MapSet.new([
      # AMERICAS
      "Briarthorn",
      "Impact",
      "Tincho",
      # APAC
      "Hi3",
      "lambyseries",
      "tom60229",
      "Tyler",
      # EUROPE
      "AyRoK",
      "Bunnyhoppor",
      "Swidz",
      "Zhym"
    ])
  end

  def relegated_gms_for_promotion({2022, 1}) do
    MapSet.new([
      # AMERICAS
      "Rami94",
      "Eddie",
      "Eggowaffle",
      "CaelesLuna",

      # APAC
      "Che0nsu",
      "che0nsu",
      "trahison",
      "DawN",
      "blitzchung",

      # EUROPE
      "Thijs",
      "Floki",
      "Warma",
      "Bozzzton"
    ])
  end

  def relegated_gms_for_promotion(_), do: MapSet.new()

  # @nationality_to_region %{
  #   "Argentina" => :US,
  #   "Belize" => :US,
  #   "Bolivia" => :US,
  #   "Brazil" => :US,
  #   "Canada" => :US,
  #   "Chile" => :US,
  #   "Colombia" => :US,
  #   "Costa Rica" => :US,
  #   "Ecuador" => :US,
  #   "El Salvador" => :US,
  #   "Guatemala" => :US,
  #   "Honduras" => :US,
  #   "Jamaica" => :US,
  #   "Mexico" => :US,
  #   "Nicaragua" => :US,
  #   "Paraguay" => :US,
  #   "Peru" => :US,
  #   "Puerto Rico" => :US,
  #   "United States of America" => :US,
  #   "United States" => :US,
  #   "USA" => :US,
  #   "Uruguay" => :US,
  #   "Venezuela" => :US,
  #   "Australia" => :AP,
  #   "Indonesia" => :AP,
  #   "Hong Kong" => :AP,
  #   "India" => :AP,
  #   "Japan" => :AP,
  #   "Macau" => :AP,
  #   "Malaysia" => :AP,
  #   "New Zealand" => :AP,
  #   "The Philippines" => :AP,
  #   "Singapore" => :AP,
  #   "South Korea" => :AP,
  #   "Taiwan" => :AP,
  #   "Thailand" => :AP,
  #   "Vietnam" => :AP,
  #   "Algeria" => :EU,
  #   "Austria" => :EU,
  #   "Bahrain" => :EU,
  #   "Belarus" => :EU,
  #   "Belgium" => :EU,
  #   "Bulgaria" => :EU,
  #   "Croatia" => :EU,
  #   "Czech Republic" => :EU,
  #   "Denmark" => :EU,
  #   "Egypt" => :EU,
  #   "Estonia" => :EU,
  #   "Finland" => :EU,
  #   "France" => :EU,
  #   "Germany" => :EU,
  #   "Greece" => :EU,
  #   "Hungary" => :EU,
  #   "Iceland" => :EU,
  #   "Iraq" => :EU,
  #   "Ireland" => :EU,
  #   "Israel" => :EU,
  #   "Italy" => :EU,
  #   "Jordan" => :EU,
  #   "Kazakhstan" => :EU,
  #   "Kuwait" => :EU,
  #   "Latvia" => :EU,
  #   "Lebanon" => :EU,
  #   "Libya" => :EU,
  #   "Lithuania" => :EU,
  #   "Luxembourg" => :EU,
  #   "Malta" => :EU,
  #   "Morocco" => :EU,
  #   "Netherlands" => :EU,
  #   "Norway" => :EU,
  #   "Oman" => :EU,
  #   "Poland" => :EU,
  #   "Portugal" => :EU,
  #   "Romania" => :EU,
  #   "Russia" => :EU,
  #   "Serbia" => :EU,
  #   "Slovakia" => :EU,
  #   "Slovenia" => :EU,
  #   "Kingdom of Saudi Arabia" => :EU,
  #   "South Africa" => :EU,
  #   "Spain" => :EU,
  #   "State of Qatar" => :EU,
  #   "Sweden" => :EU,
  #   "Switzerland" => :EU,
  #   "Tunisia" => :EU,
  #   "Turkey" => :EU,
  #   "Ukraine" => :EU,
  #   "United Arab Emirates" => :EU,
  #   "United Kingdom" => :EU,
  #   "China" => :CN
  # }

  @alpha2_to_region %{
    "KZ" => :EU,
    "PE" => :US,
    "MY" => :AP,
    "SA" => :EU,
    "TH" => :AP,
    "KW" => :EU,
    "AR" => :US,
    "AT" => :EU,
    "IT" => :EU,
    "GR" => :EU,
    "TR" => :EU,
    "JP" => :AP,
    "LT" => :EU,
    "JM" => :US,
    "BO" => :US,
    "FR" => :EU,
    "BZ" => :US,
    "QA" => :EU,
    "MO" => :AP,
    "RS" => :EU,
    "PL" => :EU,
    "HN" => :US,
    "TW" => :AP,
    "BR" => :US,
    "NL" => :EU,
    "IQ" => :EU,
    "PY" => :US,
    "CH" => :EU,
    "PH" => :AP,
    "SK" => :EU,
    "VN" => :AP,
    "CN" => :CN,
    "DZ" => :EU,
    "PT" => :EU,
    "ES" => :EU,
    "LV" => :EU,
    "UA" => :EU,
    "BH" => :EU,
    "EG" => :EU,
    "MX" => :US,
    "SV" => :US,
    "IN" => :AP,
    "LU" => :EU,
    "DE" => :EU,
    "NI" => :US,
    "CZ" => :EU,
    "HR" => :EU,
    "ZA" => :EU,
    "FI" => :EU,
    "PR" => :US,
    "IL" => :EU,
    "GB" => :EU,
    "JO" => :EU,
    "BE" => :EU,
    "DK" => :EU,
    "LB" => :EU,
    "OM" => :EU,
    "UY" => :US,
    "HU" => :EU,
    "EC" => :US,
    "NO" => :EU,
    "MA" => :EU,
    "HK" => :AP,
    "VE" => :US,
    "LY" => :EU,
    "CA" => :US,
    "SI" => :EU,
    "SE" => :EU,
    "MT" => :EU,
    "BG" => :EU,
    "IE" => :EU,
    "ID" => :AP,
    "AE" => :EU,
    "RO" => :EU,
    "NZ" => :AP,
    "RU" => :EU,
    "KR" => :AP,
    "EE" => :EU,
    "CO" => :US,
    "CR" => :US,
    "AU" => :AP,
    "GT" => :US,
    "SG" => :AP,
    "CL" => :US,
    "US" => :US,
    "TN" => :EU,
    "BY" => :EU,
    "IS" => :EU
  }
  def get_eligible_countries() do
    @alpha2_to_region |> Map.keys()
  end

  def new_grandmasters(_), do: []

  def get_grandmasters_for_promotion(season = {2020, 2}),
    do: get_grandmasters(:Jönköping, relegated_gms_for_promotion(season))

  def get_grandmasters_for_promotion(season = {2021, 1}),
    do: get_grandmasters(:Montréal, relegated_gms_for_promotion(season)) ++ ["Briarthorn"]

  def get_grandmasters_for_promotion(season = {2021, 2}),
    do: get_grandmasters(:Dalaran, relegated_gms_for_promotion(season))

  def get_grandmasters_for_promotion(season = {2022, 1}) do
    relegated = relegated_gms_for_promotion(season)
    get_grandmasters({2021, 2}) |> remove_relegated(relegated)
  end

  def get_grandmasters_for_promotion(season = {2022, 2}) do
    relegated = relegated_gms_for_promotion(season)

    newly_promoted = [
      # AM
      "Pun",
      "Pascoa",
      "CaelesLuna",
      "LeandroLeal",
      "GamerRvg",
      # APAC
      "DragonMan",
      "Mighty",
      "trahison",
      "DOLGALLERY",
      "MegaGliscor",
      "che0nsu",
      # EU
      "Furyhunter",
      "Floki",
      "SuperFake",
      "ZloyGruzin"
    ]

    retired = ["Thijs", "Surrender", "Blitzchung", "TISZ", "Muzzy", "Eddie"]

    get_grandmasters_for_promotion({2022, 1})
    |> Kernel.++(newly_promoted)
    |> Kernel.--(retired)
    |> remove_relegated(relegated)
  end

  def get_grandmasters_for_promotion(_), do: []

  def get_grandmasters({2021, 1}) do
    get_grandmasters(
      :Ironforge,
      ["justsaiyan", "撒旦降臨", "bloodyface", "Che0nsu", "Zalae", "zalae", "posesi"] |> MapSet.new()
    ) ++
      ["lunaloveee", "Tincho", "che0nsu", "Posesi"]
  end

  def get_grandmasters({2021, 2}) do
    get_grandmasters(
      :Silvermoon,
      [
        "Swidz",
        "AyRoK",
        "Zhym",
        "Hi3",
        "tom60229",
        "Tyler",
        "Tincho",
        "Briarthorn",
        "Impact",
        "撒旦降臨",
        "Alan870806",
        "posesi"
      ]
      |> MapSet.new()
    ) ++ ["GivePLZ", "AlanC86", "Posesi"]
  end

  def get_grandmasters({2022, 1}) do
    [
      "AlanC86",
      "Alutemu",
      "Bankyugi",
      "Bunnyhoppor",
      "CaelesLuna",
      "Casie",
      "che0nsu",
      "DimitriKazov",
      "DragonMan",
      "DreadEye",
      "Felkeine",
      "Fled",
      "Floki",
      "Fr0zen",
      "Frenetic",
      "Furyhunter",
      "Gaby",
      "GamerRvg",
      "GivePLZ",
      "glory",
      "grr",
      "hyung",
      "J4YOU",
      "Jarla",
      "killinallday",
      "lambyseries",
      "LeandroLeal",
      "Leta",
      "lnguagehackr",
      "lunaloveee",
      "McBanterFace",
      "MegaGliscor",
      "Mighty",
      "Monsanto",
      "Nalguidan",
      "NoHandsGamer",
      "okasinnsuke",
      "Pascoa",
      "Posesi",
      "Pun",
      "Rdu",
      "Seiko",
      "Shaxy",
      "SuperFake",
      "trahison",
      "Viper",
      "xBlyzes",
      "ZloyGruzin"
    ]
  end

  def get_grandmasters({2022, 2}) do
    [
      "Bunnyhoppor",
      "DimitriKazov",
      "Fled",
      "Furyhunter",
      "Habugabu",
      "Judgement",
      "Mighty",
      "Pascoa",
      "Posesi",
      "Pun",
      "SuperFake",
      "ZloyGruzin",
      "che0nsu",
      "levik",
      "okasinnsuke",
      "xBlyzes"
    ]
  end

  def get_grandmasters(rts = _reference_tour_stop, relegated) do
    Backend.MastersTour.list_invited_players(rts)
    |> Enum.filter(fn %{reason: r, official: _o} -> String.contains?(r, "Grandmaster") end)
    |> Enum.map(fn %{battletag_full: bf} ->
      Backend.MastersTour.InvitedPlayer.shorten_battletag(bf)
    end)
    |> remove_relegated(relegated)
    |> Enum.uniq()
  end

  def remove_relegated(gms, relegated) do
    gms
    |> Enum.filter(fn n -> !MapSet.member?(relegated, n) end)
  end

  # for people that appear differently in my source
  def hack_name(name) do
    case name do
      "muzzy" -> "Muzzy"
      "justsaiyan" -> "Justsaiyan"
      "Bunnyhoppor" -> "BunnyHoppor"
      "Briarthorn" -> "brimful"
      _ -> name
    end
  end

  @spec get_region(String.t()) :: Blizzard.region() | nil
  def get_region(full_or_short) do
    full_or_short
    |> get_country()
    |> case do
      nil -> nil
      cc -> country_to_region(cc)
    end
  end

  @spec country_to_region(String.t()) :: Blizzard.region() | nil
  def country_to_region(region_code) when region_code in ["AP", "APAC"], do: :AP
  def country_to_region(region_code) when region_code in ["EU", "EMEA"], do: :EU
  def country_to_region(region_code) when region_code in ["AM", "AMER"], do: :AM
  def country_to_region(cc), do: Map.get(@alpha2_to_region, cc)

  @spec get_country(Blizzard.battletag()) :: country_code
  def get_country(battletag_full) do
    PrioritizedBattletagCache.get_long_or_short(battletag_full)
    |> case do
      %{country: c} -> c
      _ -> nil
    end
  end

  def leaderboard_names(bts) when is_list(bts),
    do: Enum.flat_map(bts, &leaderboard_names/1)

  def leaderboard_names(battletag_full),
    do: [InvitedPlayer.shorten_battletag(battletag_full)]
end
