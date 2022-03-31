defmodule Backend.LobbyLegends.LobbyLegendsSeason do
  import TypedStruct

  @type ladder_config :: %{
    season_id: integer(),
    ap: NaiveDateTime.t(),
    eu: NaiveDateTime.t(),
    us: NaiveDateTime.t()
  }
  defmacro is_lobby_legends(lobby_legends) do
    quote do
      atoms = [
        :lobby_legends_1
      ]
      all = Enum.map(atoms, &to_string) ++ atoms
      unquote(lobby_legends) in all
    end
  end

  typedstruct enforce: true do
    field :slug, String.t()
    field :start_time, NaiveDateTime.t(), enforce: false
    field :other_streams, [String.t()]
    field :ladder, ladder_config()
    field :player_streams, %{String.t() => String.t()}
  end

  def all() do
    [
      %__MODULE__{
        slug: "lobby_legends_1",
        ladder: %{
          season_id: 5,
          ap: ~N[2022-02-28T16:00:00],
          eu: ~N[2022-02-28T23:00:00],
          us: ~N[2022-03-01T08:00:00]
        },
        other_streams: %{
          "https://twitch.tv/AntoZ31" => "AntoZ31",
          "https://www.twitch.tv/autumnwater_hs" => "AutumnWater_HS",
          "https://www.twitch.tv/ayrok_hs" => "AyRoK_HS",
          "https://www.twitch.tv/bofur_hs" => "Bofur_HS",
          "https://www.twitch.tv/dapunia" => "Dapunia",
          "https://www.twitch.tv/bobsleague" => "Bob’s League",
          "https://www.twitch.tv/cerealforme" => "Cereal For Me",
          "https://youtube.com/c/HeartCoreChannel" => "HeartCore",
          "https://www.twitch.tv/budilicious" => "Budilicious",
          "https://www.twitch.tv/howardmoonbg" => "HowardMoonBG",
          "https://www.twitch.tv/droodthund3r" => "DroodThund3r",
          "https://www.twitch.tv/liihs" => "LiiHS",
          "https://www.twitch.tv/fahrettinyalcinkaya" => "Fahrettin Yalçınkaya",
          "https://www.twitch.tv/jerakal" => "Jerakal",
          "https://www.twitch.tv/itsben321" => "ItsBen321",
          "https://www.twitch.tv/pockyplays" => "PockyPlays",
          "https://www.twitch.tv/rdulive" => "RDU",
          "https://www.twitch.tv/Sway_bae" => "Sway_bae",
          "https://www.twitch.tv/SolaryHS" => "SolaryHS",
          "https://www.twitch.tv/teamamerica" => "TeamAmericaHS",
          "https://www.twitch.tv/thefishougo" => "TheFishOugo",
          "https://www.twitch.tv/victorg_hs/videos" => "VictorG_HS"
        },
        player_streams: %{
          "baiyu" => nil,
          "Curt" => "https://www.twitch.tv/capncurt44",
          "BaboFat" => "https://www.twitch.tv/babofat",
          "guDDummit" => "https://www.twitch.tv/guddummit",
          "EducatedCollins" => "https://www.twitch.tv/educated_collins",
          "hof" => nil,
          "keromon" => "https://www.twitch.tv/keromon__sumire",
          "KenKen" => nil,
          "Maks7k" => "https://www.twitch.tv/maks7k_",
          "Satellite" => "http://twitch.tv/u/satellite_hs",
          "Ponpata07" => "https://www.twitch.tv/ponpata07",
          "SeseiSei" => "https://www.twitch.tv/seseisei",
          "summer" => nil,
          "yjSJMR" => nil,
          "ZoinhU" => "https://www.twitch.tv/zoinhu",
          "BeNice" => "https://www.twitch.tv/benice92",
        },
        start_time: ~N[2022-04-02 15:00:00]
      },
      %__MODULE__{
        slug: "lobby_legends_2",
        player_streams: %{},
        other_streams: %{},
        ladder: %{
          season_id: 5,
          ap: ~N[2022-03-31T16:00:00],
          eu: ~N[2022-03-31T23:00:00], # confirmed by eric in comp battlegrounds server https://discord.com/channels/939711967134887998/939720236599496778/959160404163035167
          us: ~N[2022-04-01T07:00:00]
        },
      }
    ]
  end

  @spec current(integer(), integer()) :: t() | nil
  def current(hours_before_start \\ 1, hours_after_start \\ 96) do
    Enum.find(all(), & current?(&1, hours_before_start, hours_after_start))
  end

  def get(slug) do
    Enum.find(all(), & to_string(slug) == to_string(&1.slug))
  end

  def current?(%{start_time: start_time}, hours_before_start \\ 1, hours_after_start \\ 96) do
    now = NaiveDateTime.utc_now()
    lower = NaiveDateTime.add(start_time, hours_before_start * -3600)
    upper = NaiveDateTime.add(start_time, hours_after_start * 3600)
    Util.in_range?(now, {lower, upper})
  end

  def players(%{player_streams: player_streams}), do: Map.keys(player_streams)
  def players(_), do: []

  def display_name(%{slug: "lobby_legends_" <> num}), do: "Lobby Legends #{num}"
  def display_name(_), do: nil
end
