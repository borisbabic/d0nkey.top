defmodule Hearthstone.Enums.BnetGameType do
  @moduledoc false

  def unknown, do: 0
  def friends, do: 1
  def ranked_standard, do: 2
  def arena, do: 3
  def vs_ai, do: 4
  def tutorial, do: 5
  def async, do: 6
  def casual_standard_newbie, do: 9
  def casual_standard_normal, do: 10
  def test1, do: 11
  def test2, do: 12
  def test3, do: 13
  def tavernbrawl_pvp, do: 16
  def tavernbrawl_1p_versus_ai, do: 17
  def tavernbrawl_2p_coop, do: 18
  def ranked_wild, do: 30
  def casual_wild, do: 31
  def fsg_brawl_vs_friend, do: 40
  def fsg_brawl_pvp, do: 41
  def fsg_brawl_1p_versus_ai, do: 42
  def fsg_brawl_2p_coop, do: 43
  def ranked_standard_new_player, do: 45
  def battlegrounds, do: 50
  def battlegrounds_friendly, do: 51
  def pvpdr_paid, do: 54
  def pvpdr, do: 55
  def reserved_18_22, do: 56
  def reserved_18_23, do: 57

  def ranked_classic, do: 58
  def casual_classic, do: 59

  def duels_types(), do: [pvpdr(), pvpdr_paid()]
  def duels?(type), do: type in duels_types()

  def standard_types(),
    do: [
      casual_standard_normal(),
      casual_standard_newbie(),
      ranked_standard(),
      ranked_standard_new_player()
    ]

  def standard?(type), do: type in standard_types()

  def wild_types(), do: [casual_wild(), ranked_wild()]
  def wild?(type), do: type in wild_types()

  def battlegrounds_types(), do: [battlegrounds(), battlegrounds_friendly()]
  def battlegrounds?(type), do: type in battlegrounds_types()

  def tavernbrawl_types(),
    do: [tavernbrawl_1p_versus_ai(), tavernbrawl_2p_coop(), tavernbrawl_pvp()]

  def tavernbrawl?(type), do: type in tavernbrawl_types()

  def fireside_gathering_types(),
    do: [fsg_brawl_1p_versus_ai(), fsg_brawl_2p_coop(), fsg_brawl_pvp(), fsg_brawl_vs_friend()]

  def fireside_gathering?(type), do: type in fireside_gathering_types()
  def fsg?(type), do: fireside_gathering?(type)

  def arena_types(), do: [arena()]
  def arena?(type), do: type in arena_types()

  def classic_types(), do: [ranked_classic(), casual_classic()]
  def classic?(type), do: type in classic_types()

  def ranked_types(),
    do: [
      pvpdr_paid(),
      pvpdr(),
      ranked_standard(),
      ranked_standard_new_player(),
      ranked_wild(),
      ranked_classic(),
      battlegrounds()
    ]

  def ranked?(type), do: type in ranked_types()

  def ladder_types(), do: [ranked_standard(), ranked_wild(), ranked_standard_new_player()]
  def ladder?(type), do: type in ladder_types()

  def constructed_types(),
    do: wild_types() ++ standard_types() ++ classic_types() ++ [friends(), vs_ai()]

  def constructed?(type), do: type in constructed_types()

  def game_type_name(type) when is_integer(type) do
    cond do
      wild?(type) -> "Wild"
      standard?(type) -> "Standard"
      battlegrounds?(type) -> "Battlegrounds"
      tavernbrawl?(type) -> "Tavern Brawl"
      duels?(type) -> "Duels"
      fsg?(type) -> "Fireside Gathering"
      arena?(type) -> "Arena"
      classic?(type) -> "Classic"
      true -> "Unknown"
    end
  end

  def game_type_name(type) when is_binary(type) do
    normalize = &(&1 |> String.downcase() |> String.replace(" ", ""))

    [
      "Wild",
      "Standard",
      "Battlegrounds",
      "Tavern Brawl",
      "Duels",
      "Fireside Gathering",
      "Arena",
      "Classic"
    ]
    |> Enum.find("Unknown", &(normalize.(&1) == normalize.(type)))
  end

  def game_type_name(_), do: "Unknown"
end

defmodule Hearthstone.Enums.Format do
  @moduledoc false
  @all [{:wild, 1, "Wild"}, {:standard, 2, "Standard"}, {:classic, 3, "Classic"}]

  @all
  |> Enum.each(fn {down, num, name} ->
    def unquote(down)(), do: unquote(num)
    def name(unquote(num)), do: unquote(name)
    defp down_parse(unquote(down |> to_string())), do: unquote(num)
  end)

  def name(_), do: nil
  @spec name(integer(), integer()) :: String.t()
  def name(real, fallback), do: name(real) || name(fallback)

  defp down_parse(_), do: nil

  def parse(name) do
    name
    |> String.downcase()
    |> down_parse()
  end

  @spec all() :: [{integer(), String.t()}]
  def all() do
    @all |> Enum.map(fn {_, id, name} -> {id, name} end)
  end
end
