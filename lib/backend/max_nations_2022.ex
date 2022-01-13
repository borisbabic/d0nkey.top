defmodule Backend.MaxNations2022 do
  @moduledoc false

  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.Hearthstone.Lineup
  alias Backend.Battlenet.Battletag

  def rosters() do
    %{
      "Argentina" => [ "Nalguidan#1733", "Rusinho#11447", "Tincho#1287" ],
      "Australia" => [ "WetGoose#11793", "ColdSnapSp#1674", "Coolkid2001#1483" ],
      "Austria" => [ "DrGyros#2771", "Khamûl#2139", "ThisIsChris#21601" ],
      "Belgium" => [ "BabyBear#21485", "Aikoio#2380", "Floki#2706" ],
      "Brazil" => [ "Fled#1956", "NaySyl#1496", "Rase#1355" ],
      "Bulgaria" => [ "Jengo#2254", "Felzak#2429", "Krisofive#2974" ],
      "Canada" => [ "Lnguagehackr#1412", "CaelesLuna#1906", "Eddie#13500" ],
      "Chile" => [ "DarkClaw#1695", "Blowns#1770", "Mokranichile#1591" ],
      "China" => [ "XiaoT#11924", "快樂之潛行者#1893", "Syf#11980" ],
      "Croatia" => [ "Reqvam#2191", "D0nkey#2470", "Paljuha#2621" ],
      "Czech Republic" => [ "Faeli#2572", "En1gma#21477", "Jarla#21553" ],
      "Denmark" => [ "Furyhunter#2166", "Hygs#2243", "Ziptopz#2225" ],
      "Finland" => [ "Habugabu#2467", "Detto#2234", "Lasagne#21761" ],
      "France" => [ "AyRoK#2374", "Dreivo#2948", "xBlyzes#2682" ],
      "Germany" => [ "Seiko#2721", "Burr0#2510", "ChaboDennis#2598" ],
      "Greece" => [ "Athanas#1830", "RST#1316", "SomiTequila#2763" ],
      "Hungary" => [ "CheeseHead#2178", "Hulkeinstein#2138", "Wuncler#2394" ],
      "India" => [ "Ronak#11268", "Gcttirth#1560", "Mighty#1147" ],
      "Israel" => [ "IdanProK#21626", "CrazyMage#211783", "Falular#2213" ],
      "Italy" => [ "Leta#21458", "Cikos#21544", "Gregoriusil#2794" ],
      "Japan" => [ "Jimon#11850", "MegaGliscor#1122", "Okasinnsuke#1294" ],
      "Lithuania" => [ "Benetoo#2723", "gr0nas#2715", "s8ris#2419" ],
      "Luxembourg" => [ "wiRer#2160", "Alexisdiesel#2901", "Thedemon#21100" ],
      "Malaysia" => [ "EzXarT#6135", "Auria#21504", "SithX#6640" ],
      "Mexico" => [ "IrvinG#1619", "Ekrow#1825", "Empanizado#1147" ],
      "Netherlands" => [ "Maxvdp#21410", "Cptnkitty#2235", "Këlthrag#2798" ],
      "New Zealand" => [ "Ace103#1126", "Jakattack#1815", "LordZeoLite#1957" ],
      "Norway" => [ "Vannsprutarn#2908", "Elefanti#21578", "Gjrstad#2676" ],
      "Peru" => [ "UchihaSaske#11453", "InfErnO#12406", "Kaloz#11658" ],
      "Philippines" => [ "WaningMoon#1397", "IAmTheTable#1415", "TheBigMac#1326" ],
      "Poland" => [ "Myzrael#2482", "Dawido#2832", "Mikolop#2935" ],
      "Portugal" => [ "SuperFake#2167", "DrBoom#2349", "Ferno4111#2518" ],
      "Romania" => [ "FinalS#2908", "Serj#22394", "Sharpy#22918" ],
      "Russia" => [ "y0ungchrisT#2130", "Levik#2797", "Noflame#2377" ],
      "Serbia" => [ "Blankieh#1227", "Brazuka#21824", "Sumskiduh#2472" ],
      "Singapore" => [ "Lambyseries#1852", "SGAhIce#6720", "Skye#1757" ],
      "Slovakia" => [ "HiImJoZo#2223", "JEJBenkoJEA#2497", "Rjú#2170" ],
      "South Korea" => [ "Grr#31290", "Ostinato#31524", "Sinah#31954" ],
      "Spain" => [ "L3bjorge#2966", "Frenetic#2377", "BruTo#21173" ],
      "Sweden" => [ "Orange#23456", "Chewie#21810", "Sensei6#2330" ],
      "Switzerland" => [ "TheRabbin#2401", "GAP1698#2858", "RockyN1#2773" ],
      "Taiwan" => [ "Shaxy#4385", "山下智久#3502", "西陵珩#3799" ],
      "Thailand" => [ "Bankyugi#1988", "eCrazy#11771", "Phai#11410" ],
      "Turkey" => [ "Hypnos#21372", "Rocco#22899", "Whiterun#21522" ],
      "United Kingdom" => [ "DeadDraw#2311", "Jambre#1597", "PocketTrain#2645" ],
      "Ukraine" => [ "iNS4NE#21840", "Silvors#21299", "Zoltan#2312" ],
      "Uruguay"=> [ "Zorb#11411", "Donat#11680", "Loreance#1900" ],
      "United States" => [ "McBanterFace#1422", "Eggowaffle#1337", "GamerRvg#1410" ]
    }
  end
  def first_stage_groups() do
      %{
        "A" => [ "Brazil", "Spain", "Poland", "Australia" ],
        "B" => [ "Argentina", "Thailand", "Serbia", "Austria" ],
        "C" => [ "Canada", "Croatia", "Romania", "Philippines" ],
        "D" => [ "United States", "Portugal", "India", "Russia" ],
        "E" => [ "UK", "Mexico", "Netherlands", "New Zealand" ],
        "F" => [ "France", "Denmark", "Malaysia", "Uruguay" ],
        "G" => [ "Sweden", "Germany", "Israel", "Peru" ],
        "H" => [ "Czech Republic", "Ukraine", "Taiwan", "Luxembourg" ],
        "I" => [ "Singapore", "Finland", "Chile", "Slovakia" ],
        "J" => [ "Korea", "Turkey", "Hungary", "Lithuania" ],
        "K" => [ "China", "Belgium", "Greece", "Bulgaria" ],
        "L" => [ "Japan", "Italy", "Norway", "Switzerland" ]
      }
  end

  defp normalize_btag(btag), do: btag |> Battletag.shorten() |> String.downcase()
  def get_nation(battletag) do
    Enum.find_value(rosters(), fn {country, roster} ->
      normalized_btag = normalize_btag(battletag)
      normalized_roster = Enum.map(roster, &normalize_btag/1)
      if normalized_btag in normalized_roster do
        country
      end
    end)
  end

  def lineup_tournament_source(), do: "max_nations_2022"

  def get_latest_lineups_tournament_id() do
    base_lineup_query()
    |> select([l], l.tournament_id)
    |> limit(1)
    |> Repo.one()
  end
  def get_possible_lineups_tournament_id() do
    query = from l in Lineup,
      select: l.tournament_id,
      where: l.tournament_source == ^lineup_tournament_source(),
      group_by: l.tournament_id

    Repo.all(query)
  end

  def get_nation_lineups(nation), do: get_lineups(nation)
  def get_player_lineups(player), do: get_lineups(player)
  defp get_lineups(thing) do
    search = "%#{thing}%"
    base_lineup_query()
    |> preload([l], :decks)
    |> where([l], ilike(l.name, ^search))
    |> Repo.all()
  end

  defp base_lineup_query() do
    from l in Lineup,
      where: l.tournament_source == ^lineup_tournament_source(),
      order_by: [desc: l.inserted_at]
  end

  def live?() do
    Twitch.HearthstoneLive.streams()
    |> Enum.any?(& &1.user_name == "MAXTeamTV" && String.downcase(&1.title) =~ "nation")
  end

end
