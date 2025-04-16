defmodule Backend.LeaderboardsPoints.HsEsports2025 do
  @moduledoc "HsEsports 2023 2024 system"
  alias Backend.LeaderboardsPoints.PointsSystem
  alias Backend.Blizzard
  @behaviour PointsSystem

  @season_mapper [
    {"2025", "spring", 137, ["STD"]},
    {"2025", "spring", 138, ["STD"]},
    {"2025", "summer", 140, ["STD"]},
    {"2025", "summer", 141, ["STD"]},
    {"2025", "last-chance", 143, ["STD"]},
    {"2025", "last-chance", 144, ["STD"]}
  ]

  @spec points_for_rank(rank :: integer()) ::
          {:ok, points :: integer()} | {:error, error :: atom()}
  @impl true
  def points_for_rank(r) when r < 1, do: {:error, :rank_below_one}
  def points_for_rank(1), do: {:ok, 7}
  def points_for_rank(r) when r <= 5, do: {:ok, 6}
  def points_for_rank(r) when r <= 10, do: {:ok, 5}
  def points_for_rank(r) when r <= 25, do: {:ok, 4}
  def points_for_rank(r) when r <= 50, do: {:ok, 3}
  def points_for_rank(r) when r <= 75, do: {:ok, 2}
  def points_for_rank(r) when r <= 100, do: {:ok, 1}
  def points_for_rank(_), do: {:ok, 0}

  @impl true
  def filter_player_rows(rows, _, _) do
    # TODO: Make it aware of past stuff
    Enum.filter(rows, fn {account_id, _, _} ->
      !Blizzard.ineligible?(account_id, NaiveDateTime.utc_now())
    end)
  end

  @spec points_for_rank!(rank :: integer()) :: points :: integer()
  @impl true
  def points_for_rank!(r) do
    case points_for_rank(r) do
      {:ok, points} -> points
      {:error, error} -> raise to_string(error)
    end
  end

  @impl true
  def get_relevant_ldb_regions(_season_slug, _leaderboard_id) do
    [:EU, :US, :AP]
  end

  @impl true
  def max_rank(_, _), do: 100

  @doc """
  Gets the leaderboard seasons used for calculating points for the points season `ps`
  """
  @impl true
  def get_relevant_ldb_seasons(ps, leaderboard_id, use_current) do
    get_leaderboard_seasons(ps, leaderboard_id) |> remove_too_soon(use_current)
  end

  def get_leaderboard_seasons(points_season, leaderboard_id_raw) do
    id = to_string(leaderboard_id_raw)

    case String.split(points_season, "_") do
      [year, season] ->
        Enum.filter(@season_mapper, fn {y, s, _, ids} -> y == year && s == season && id in ids end)
        |> Enum.map(&extract_season/1)

      [year] ->
        Enum.filter(@season_mapper, fn {y, _, _, ids} -> y == year && id in ids end)
        |> Enum.map(&extract_season/1)
    end
  end

  @impl true
  def points_seasons() do
    @season_mapper
    |> Enum.filter(&elem(&1, 1))
    |> Enum.flat_map(fn {year, season, _, _} -> [year, "#{year}_#{season}"] end)
    |> Enum.uniq()
  end

  @impl true
  def replace_entries(entries, ps, leaderboard_id) do
    case hardcoded_seasons(ps, leaderboard_id) do
      [] ->
        entries

      seasons ->
        good_entries = entries |> Enum.filter(&(&1.season.season_id not in seasons))

        hardcoded_entries =
          seasons
          |> Enum.flat_map(fn season_id ->
            Enum.map(hardcoded_tuples(137), fn
              {account_id, _points, rank} ->
                Backend.LeaderboardsPoints.create_fake_entry(account_id, rank, season_id)
            end)
          end)

        hardcoded_entries ++ good_entries
    end
  end

  defp hardcoded_seasons("2025", "STD"), do: [137]
  defp hardcoded_seasons("2025_spring", "STD"), do: [137]
  defp hardcoded_seasons(_, _), do: []

  @impl true
  def info_links("2025" <> _ = season) do
    [
      %{
        link: "https://hearthstone.blizzard.com/en-us/news/24180851",
        display: "2025 Announcement"
      }
      | season_specific_links(season)
    ]
  end

  def info_links(_) do
    [
      %{
        link: "https://hearthstone.blizzard.com/news/esports",
        display: "Hearthstone Esports News"
      }
    ]
  end

  ######
  def season_specific_links(ps) when ps in ["2025", "2025_spring"] do
    [
      %{
        link:
          "https://bnetcmsus-a.akamaihd.net/cms/content_entry_media/it/ITJPBG8SPQOP1744133921898.pdf",
        display: "Source for March"
      }
    ]
  end

  def season_specific_links(_), do: []

  def current_points_season() do
    current = Blizzard.current_constructed_season_id()

    case Enum.find(@season_mapper, &(current == elem(&1, 2) && elem(&1, 1))) do
      {year, season, _, _} -> "#{year}_#{season}"
      _ -> Blizzard.now().year |> to_string()
    end
  end

  defp remove_too_soon(seasons, use_current) do
    comparator = if use_current, do: &Kernel.<=/2, else: &Kernel.</2
    current = Blizzard.current_constructed_season_id()
    Enum.filter(seasons, &comparator.(&1, current))
  end

  defp extract_season({_, _, s, _}), do: s

  defp hardcoded_tuples(137) do
    [
      {"Superman", 7, 1},
      {"PocketTrain", 7, 1},
      {"Tobyka", 7, 1},
      {"Incurro", 6, 2},
      {"gyu", 6, 2},
      {"karma", 6, 2},
      {"Furyhunter", 6, 3},
      {"Derpinox", 6, 3},
      {"Casie", 6, 3},
      {"maxiebon1234", 6, 3},
      {"iNS4NE", 6, 4},
      {"西陵珩", 6, 4},
      {"眠たげなクマ", 6, 4},
      {"mmf", 6, 4},
      {"Janos", 6, 5},
      {"SAVOR", 6, 5},
      {"Definition", 6, 5},
      {"uikyou", 6, 5},
      {"PRTHNCA", 5, 6},
      {"ДикийЗверь", 5, 6},
      {"Jarla", 5, 7},
      {"Jiuqianyu", 5, 7},
      {"evanhansen", 5, 7},
      {"Lasagne", 5, 8},
      {"GamerRvg", 5, 8},
      {"Mesmile", 5, 8},
      {"maxchen", 5, 9},
      {"Ryan223437", 5, 9},
      {"henrikk", 5, 9},
      {"reqvam", 5, 10},
      {"levik", 4, 11},
      {"hemlock", 4, 11},
      {"Mencke", 4, 11},
      {"Photon", 4, 12},
      {"Shaxy", 4, 12},
      {"tepepe", 4, 13},
      {"Cash", 4, 13},
      {"小トトロ", 4, 13},
      {"Rine", 4, 14},
      {"香菇奾汁", 4, 14},
      {"sinah", 4, 15},
      {"DeaadGame", 4, 15},
      {"ThijsNL", 4, 16},
      {"Sabertan", 4, 16},
      {"Tansoku", 4, 16},
      {"FilFeel", 4, 17},
      {"Hi3", 4, 17},
      {"fire", 4, 17},
      {"Ice", 4, 18},
      {"とりげ", 4, 19},
      {"CritECal", 4, 19},
      {"morizo", 4, 19},
      {"Ko1ind", 4, 20},
      {"Sialed", 4, 20},
      {"C8763", 4, 20},
      {"santamaks", 4, 21},
      {"Hypnos", 4, 21},
      {"Ame", 4, 22},
      {"NAGON", 4, 22},
      {"Aquaman575", 4, 22},
      {"jambre", 4, 23},
      {"星殞晨風", 4, 23},
      {"digo", 4, 23},
      {"Noflame", 4, 24},
      {"Hero", 4, 24},
      {"XiaoZ", 4, 24},
      {"가끔들어옴", 4, 25},
      {"eswaff", 4, 25},
      {"PingONi", 3, 26},
      {"djGRINK", 3, 26},
      {"MrNacho", 3, 27},
      {"Nin123", 3, 27},
      {"kiki", 3, 28},
      {"McBanterFace", 3, 28},
      {"ustyacmd", 3, 29},
      {"LLIoKoJIaD", 3, 29},
      {"Ryvius", 3, 29},
      {"大78", 3, 29},
      {"fing451", 3, 30},
      {"curry", 3, 30},
      {"SrBerserk", 3, 31},
      {"박효성", 3, 31},
      {"Rot", 3, 31},
      {"YrXiaoT", 3, 32},
      {"霜月散丶", 3, 32},
      {"雨後見", 3, 32},
      {"Sidi", 3, 33},
      {"プラス", 3, 33},
      {"GameBreaker", 3, 34},
      {"yilimi", 3, 34},
      {"CrazyCat", 3, 34},
      {"Gaboumme", 3, 35},
      {"くろふ", 3, 35},
      {"Matthew", 3, 35},
      {"XiaoShan", 3, 35},
      {"Przyszłość", 3, 36},
      {"很星爆你知道嗎", 3, 36},
      {"miniwinnie", 3, 36},
      {"Darq7007", 3, 37},
      {"Mamoulou", 3, 37},
      {"TIZS", 3, 37},
      {"NikitaStar", 3, 38},
      {"FaceOff", 3, 39},
      {"Edwin", 3, 39},
      {"CaelesLuna", 3, 39},
      {"evta", 3, 40},
      {"Dizdemon", 3, 40},
      {"Steelraiser", 3, 40},
      {"Maop", 3, 41},
      {"OuO", 3, 41},
      {"zlsjs", 3, 41},
      {"Ghost", 3, 42},
      {"NoHandsGamer", 3, 42},
      {"KiRiLLoiD", 3, 42},
      {"sailio", 3, 43},
      {"KOmeta", 3, 43},
      {"StEyes11", 3, 44},
      {"Sooni", 3, 44},
      {"Dssc1234", 3, 44},
      {"obivankenobi", 3, 45},
      {"送頭型玩家", 3, 45},
      {"Nameless", 3, 46},
      {"承泰不要", 3, 46},
      {"Lucasdmnasc", 3, 46},
      {"JumpyLion", 3, 47},
      {"William", 3, 48},
      {"preie", 3, 48},
      {"BloodKing", 3, 49},
      {"도규철", 3, 49},
      {"XiaoT", 3, 50},
      {"슈퍼곰", 3, 50},
      {"Youth", 2, 51},
      {"katagami", 2, 51},
      {"DimitriKazov", 2, 51},
      {"kvgp", 2, 52},
      {"Daisr", 2, 52},
      {"Shomaru", 2, 52},
      {"띠용", 2, 53},
      {"lnguagehackr", 2, 53},
      {"JiBoDa", 2, 53},
      {"BabyBear", 2, 54},
      {"MERO", 2, 54},
      {"Scout", 2, 54},
      {"Norwis", 2, 55},
      {"coupon", 2, 55},
      {"KiritoFan69", 2, 55},
      {"fsorace1", 2, 55},
      {"ChaboDennis", 2, 56},
      {"caravaggio8", 2, 56},
      {"Tatamisasi", 2, 56},
      {"OTGchu", 2, 57},
      {"진원치킨", 2, 57},
      {"sunq", 2, 57},
      {"Zantler", 2, 58},
      {"NotBamity", 2, 58},
      {"PIONER", 2, 59},
      {"AlanC86", 2, 59},
      {"Giotto", 2, 59},
      {"KarkinggHS", 2, 60},
      {"pikahara", 2, 60},
      {"kanaya", 2, 60},
      {"Yeins", 2, 60},
      {"Fatty", 2, 61},
      {"yyzzss", 2, 61},
      {"Siurvk", 2, 61},
      {"최석중", 2, 62},
      {"Empanizado", 2, 62},
      {"cherryman", 2, 62},
      {"iGShuiMo", 2, 63},
      {"Drunkyboy", 2, 63},
      {"Arashi", 2, 63},
      {"Holmström", 2, 64},
      {"Deviant", 2, 64},
      {"簡簡", 2, 64},
      {"かわすけ", 2, 65},
      {"LickThatGoat", 2, 65},
      {"Nightmare14", 2, 66},
      {"Kubu", 2, 66},
      {"Excelia", 2, 66},
      {"Umbrage", 2, 67},
      {"까마귀", 2, 67},
      {"AgentPWE", 2, 67},
      {"balance", 2, 68},
      {"김태건", 2, 68},
      {"RobertJ", 2, 68},
      {"Turbon1ck", 2, 69},
      {"Dergachev", 2, 69},
      {"Waffles", 2, 69},
      {"Ucuun", 2, 70},
      {"DDoBaGi", 2, 70},
      {"Roulian", 2, 71},
      {"РезвыйМишка", 2, 71},
      {"NQCL", 2, 72},
      {"알파카", 2, 72},
      {"duriwinner", 2, 73},
      {"Neo", 2, 73},
      {"Farbz", 2, 73},
      {"Theo", 2, 74},
      {"OneManul83", 2, 74},
      {"InFerNo", 2, 74},
      {"Lancelot", 2, 75},
      {"TheYavuz", 2, 75},
      {"Habugabu", 1, 76},
      {"duckweedzz", 1, 76},
      {"令和散步", 1, 76},
      {"maneti", 1, 77},
      {"Bighouse", 1, 77},
      {"Chewie", 1, 78},
      {"Clem", 1, 78},
      {"현명한로나", 1, 78},
      {"CeXX", 1, 78},
      {"KYOKiE", 1, 79},
      {"Patek", 1, 79},
      {"テンポロ応援団", 1, 79},
      {"player22cm", 1, 79},
      {"bieberfever", 1, 80},
      {"戰爭之王", 1, 80},
      {"오빠차", 1, 81},
      {"DreadEye", 1, 81},
      {"Pticman", 1, 81},
      {"method4s", 1, 82},
      {"神馬似情", 1, 82},
      {"Night", 1, 82},
      {"danny1001", 1, 82},
      {"Daydreamin", 1, 83},
      {"聖水洋洋", 1, 83},
      {"Snufkin", 1, 84},
      {"SEEAN616", 1, 84},
      {"Gregoriusil", 1, 85},
      {"가끔들어옴", 1, 85},
      {"Cassia", 1, 85},
      {"Bluehammerbr", 1, 86},
      {"A38X", 1, 86},
      {"누욱비", 1, 86},
      {"Kippalicious", 1, 86},
      {"たかやん", 1, 87},
      {"amazingoo", 1, 87},
      {"ecaranda", 1, 87},
      {"진원치킨", 1, 88},
      {"러블리즈화이팅", 1, 88},
      {"MCweifu", 1, 88},
      {"Cho", 1, 89},
      {"AKO", 1, 89},
      {"ITE", 1, 89},
      {"四六九八九一", 1, 90},
      {"Etheris", 1, 90},
      {"Berkut", 1, 91},
      {"承泰不要", 1, 91},
      {"Kasai", 1, 91},
      {"Wumbo", 1, 91},
      {"Jesuis1", 1, 92},
      {"bspnbvpaae", 1, 92},
      {"sherlock", 1, 93},
      {"Rachel", 1, 93},
      {"Mills", 1, 93},
      {"Artisan", 1, 93},
      {"Chintzy", 1, 94},
      {"Htj", 1, 94},
      {"Thus", 1, 95},
      {"LEBED", 1, 95},
      {"BongDaCity", 1, 96},
      {"sang", 1, 96},
      {"Sparky", 1, 96},
      {"PekoTea", 1, 96},
      {"Construct", 1, 97},
      {"ASDG", 1, 97},
      {"vacantplace", 1, 97},
      {"Asuna", 1, 98},
      {"Nias", 1, 98},
      {"fumika", 1, 98},
      {"glory", 1, 99},
      {"Haztlan", 1, 99},
      {"evchwz", 1, 99},
      {"ZoHaN", 1, 100},
      {"かやのん", 1, 100},
      {"yutan", 1, 100},
      {"xenon", 1, 100}
    ]
  end
end
