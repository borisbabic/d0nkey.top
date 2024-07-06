defmodule ScratchPad do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.CardGameTally
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.CardMulliganDto
  alias Hearthstone.DeckTracker.CardDrawnDto
  alias Backend.Hearthstone.Deck
  alias Backend.MastersTour.InvitedPlayer

  def num_finals_losers_first_3_weeks_qualified(tour_stop) do
    invited = Backend.MastersTour.list_invited_players(tour_stop)

    invited_short =
      MapSet.new(invited, fn i -> InvitedPlayer.shorten_battletag(i.battletag_full) end)

    Backend.MastersTour.list_qualifiers_for_tour(tour_stop)
    |> Enum.sort_by(fn q -> q.start_time end, :asc)
    |> Enum.take(45)
    |> Enum.map(fn q -> q.standings |> Enum.find(fn s -> s.position == 2 end) end)
    |> Enum.filter(fn fl ->
      MapSet.member?(invited_short, InvitedPlayer.shorten_battletag(fl.battletag_full))
    end)
    |> Enum.count()
  end

  def example_deck() do
    """
      {
          "deck": [
              436,
              581,
              859,
              860,
              974,
              974,
              1092,
              52058,
              52058,
              52698,
              52698,
              53739,
              53756,
              53947,
              53947,
              54885,
              54885,
              54891,
              54891,
              54892,
              54892,
              54893,
              54893,
              54894,
              54894,
              55441,
              56307,
              57193,
              57193,
              57326
          ],
          "hero": 893,
          "format": 2,
          "rank": 9,
          "legend_rank": 0,
          "game_type": 2,
          "twitch": {
              "login": "bebumoon1",
              "display_name": "BebuMoon1",
              "id": "87237382"
          }
      }
    """
    |> Poison.decode!()
  end

  def encode_deck() do
    d = example_deck()

    cards =
      d["deck"]
      |> Enum.frequencies()
      |> Enum.group_by(fn {_card, freq} -> freq end, fn {card, _freq} -> card end)

    ([
       0,
       1,
       d["format"],
       1,
       d["hero"],
       Enum.count(cards[1])
     ] ++
       cards[1] ++
       [Enum.count(cards[2])] ++
       cards[2] ++
       [0])
    |> Enum.into([], fn bit -> Varint.LEB128.encode(bit) end)
  end

  def parse_hearthstone_json() do
    with {:ok, body} <- File.read("lib/data/collectible.json"),
         {:ok, json} <- body |> Poison.decode() do
      json |> Enum.map(&Backend.HearthstoneJson.Card.from_raw_map/1)
    end
  end

  def fudov(d, player \\ "FudoV#") do
    sum =
      %{fudov: fudov, ta_win: wins, ta_loss: losses, player_count: count} =
      d
      |> Enum.filter(fn %{standings: standings} ->
        standings |> Enum.any?(&(&1.team.name =~ player))
      end)
      |> Enum.reduce(%{fudov: 0, ta_win: 0, ta_loss: 0, player_count: 0}, fn %{
                                                                               standings:
                                                                                 standings
                                                                             },
                                                                             %{
                                                                               fudov: f,
                                                                               ta_win: taw,
                                                                               ta_loss: tal,
                                                                               player_count: pc
                                                                             } ->
        {auto_wins, auto_losses} =
          standings
          |> Enum.reduce({0, 0}, fn s, {aw, al} ->
            {aw + (s.auto_wins || 0), al + (s.auto_losses || 0)}
          end)

        fudov_auto = Enum.find_value(standings, 0, &(&1.team.name =~ player && &1.auto_wins))
        total = Enum.count(standings)

        %{
          fudov: f + fudov_auto,
          ta_win: taw + auto_wins,
          ta_loss: tal + auto_losses,
          player_count: pc + total
        }
      end)

    expected = (wins - losses) / count
    expected_alt = wins / count
    IO.inspect("Expected: #{expected} Expected_alt: #{expected_alt} fudov: #{fudov}")
    sum
  end

  def all_mt_participants() do
    Backend.MastersTour.TourStop.all()
    |> Enum.filter(& &1.battlefy_id)
    # |> Enum.flat_map(& Backend.Battlefy.get_participants(&1.battlefy_id))
    |> Enum.flat_map(fn %{id: id, battlefy_id: battlefy_id} ->
      battlefy_id
      |> Backend.Battlefy.get_participants()
      |> Enum.map(fn %{name: name, user_id: user_id} ->
        fixed_name = fix_name(name)
        {fix_name(name), user_id, Backend.PlayerInfo.get_country(fixed_name), id}
      end)
    end)
  end

  def fix_name(name) do
    name
    |> Backend.MastersTour.fix_name()
    |> Backend.Grandmasters.PromotionCalculator.get_group_by()
  end

  def find_same_mt_players() do
    all_mt_participants()
    |> find_same_mt_players()
  end

  def find_same_mt_players(all_participants) do
    all_participants
    # |> Enum.map(& {fix_name(&1.name), &1.user_id})
    |> Enum.group_by(&elem(&1, 1))
    |> Enum.map(fn {user_id, list} -> {user_id, Enum.uniq_by(list, &elem(&1, 0))} end)
    |> Enum.filter(fn {_user_id, list} -> Enum.count(list) > 1 end)
  end

  def create_map({_user_id, parts}), do: parts |> Enum.reverse() |> create_map()

  def create_map([curr = {<<"Backup", _::bitstring>>, _, _} | rest]),
    do: create_map(rest ++ [curr])

  def create_map([{current, _, _} | rest]) do
    rest
    |> Enum.map(fn {name, _, _} ->
      """
      "#{name}" -> "#{current}"
      """
    end)
    |> Enum.join("\n")
  end

  # imported decks from prod and had duplicates
  # I don't know how the fuck that happened either
  def deduplicate_decks() do
    deck_ids = duplicate_deck_ids()

    query =
      from d in Deck,
        where: d.id in ^deck_ids

    decks = Repo.all(query)

    decks
    |> Enum.group_by(& &1.id)
    |> Enum.chunk_every(50)
    |> Enum.each(&delete_grouped_by/1)
  end

  defp delete_grouped_by(grouped_by) do
    grouped_by
    |> Enum.reduce(Multi.new(), fn {_, [a | _]}, multi ->
      query =
        from d in Deck,
          where: d.id == ^a.id,
          where: d.inserted_at == ^a.inserted_at,
          where: d.deckcode == ^a.deckcode

      Multi.delete_all(multi, "deck_id_#{a.id}", query)
    end)
    |> Repo.transaction()
  end

  defp duplicate_deck_ids() do
    query =
      from d in Deck,
        group_by: d.id,
        having: count(1) > 1,
        select: d.id

    Repo.all(query)
  end

  def generate_false_card_stats(%{
        id: game_id,
        player_deck: %{cards: cards},
        player_has_coin: coin
      }) do
    shuffled = Enum.shuffle(cards)
    mull_num = if coin, do: 4, else: 3
    drawn_num = Enum.random(1..20)

    mull_dtos =
      shuffled
      |> Enum.take(mull_num)
      |> Enum.map(fn card_id ->
        %CardMulliganDto{
          card_dbf_id: card_id,
          kept: Enum.random([true, false])
        }
      end)

    drawn_dtos =
      shuffled
      |> Enum.drop(mull_num)
      |> Enum.take(drawn_num)
      |> Enum.map(fn card_id ->
        %CardDrawnDto{
          card_dbf_id: card_id,
          turn: Enum.random(1..10)
        }
      end)

    {:ok, ecto_attrs} = GameDto.create_card_tally_ecto_attrs(mull_dtos, drawn_dtos, game_id)
    Repo.insert_all(CardGameTally, ecto_attrs)
  end

  def generate_false_card_stats(num_games) when is_integer(num_games) do
    from(g in Game,
      join: pd in assoc(g, :player_deck),
      preload: [player_deck: pd],
      where: pd.format == 2,
      limit: ^num_games
    )
    |> Repo.all()
    |> Enum.each(&generate_false_card_stats/1)
  end

  def deduplicate_played(
        criteria \\ [
          {"period", "past_2_weeks"},
          {"rank", "diamond_to_legend"},
          {"min_games", 100}
        ]
      ) do
    DeckTracker.deck_stats(criteria)
    |> Enum.map(fn %{deck_id: deck_id, total: total} -> {total, deck_id} end)
    |> Enum.group_by(fn {_, d} -> Backend.Hearthstone.get_deck(d) |> Deck.deckcode() end)
    |> Enum.filter(fn {_, g} -> Enum.count(g) > 1 end)
    |> Enum.sort_by(fn {_, g} -> Enum.map(g, &elem(&1, 0)) |> Enum.sum() end, :desc)
    |> Enum.map(fn {_, g} -> Enum.map(g, &elem(&1, 1)) end)
    |> Enum.each(&Backend.Hearthstone.deduplicate_ids/1)
  end

  def whizbang_codes_code(deck_codes \\ nil) do
    (deck_codes || whizbang_decks())
    |> Enum.map(&Backend.Hearthstone.Deck.decode!/1)
    |> Enum.map(& &1.cards)
    |> Enum.map(fn cards ->
      uniq =
        for card_id <- cards,
            %{name: name} <- [Backend.Hearthstone.get_card(card_id)],
            uniq: true,
            do: name

      list_inner = uniq |> Enum.map_join(" , ", &"\"#{&1}\"")
      {Enum.count(uniq), list_inner}
    end)
    |> Enum.map_join(" or ", fn {count, parts} ->
      "min_count?(ci, #{count}, [#{parts}])"
    end)
  end

  @original_splendiferous_decks [
    "AAEBAfHhBAKXoATrmAYOqIEErYoEiZ8Ej58EnJ8Etp8EjboEkNQEiPYE1c4FyvYFpP8F2aIG1agGAAA=",
    "AAEBAea5AwOBpga/sAbJsAYMgIUEgZ8Eg58Etp8E1J8E7KAE4fgF7Z8Gu7AGvrAGw7AGzLEGAb31BgMA",
    "AAEBAZICAAVf5AjougOgoAaJoQYBhLUGFAA=",
    "AAEBAR8AD9YRyRTKFIO5A7a7A+GfBMeyBNShBe+iBeKkBerKBdj2BdP4BeSYBv6lBgAA",
    "AAEBAf0EAAAB9r8GHgA=",
    "AAEBAZ8FHuIRwxaFF4cX1K4C5q4C48sC7dIC/fsC7IYDg6ED9KIDkqQDpqUD/acD9awD/a0DkK4D/q8DkbEDjLYDysEDnJ8EnZ8E658E7Z8E7p8EtaIE96QE5bAEAAAA",
    "AAEBAa0GBb6fBMGfBJbUBM/GBaSdBgnXCq2KBISfBIWfBIakBbu4Bfv4BeOABpegBgGm8QUHAA==",
    "AAEBAaIHA6aKBK+nBoqoBguSnwT2nwTuoASMpAXXwwXfwwXo+gXungatpwazqQbLqQYAAA==",
    "AAEBAaoIBNoPhBecmwPW0gYN2A/SE+e7ArbNAoyUA8aZA6+nA7PoA5XwA9WyBMXOBMbOBIf7BQAA",
    "AAEBAf0GBtKZA4adA/DtA/PtA9/CBazpBQfx7QOWlwaEngbBnwbLnwaroAb3owYAAA==",
    "AAEBAQcMlBeS+AKrkQOskQOtkQOvkQOwkQOSlwOXlwO5mQPrmwPIngYJtJEDjZcDj5cD2psD+qQD+aUD9agD2a0D6pYEAAA=",
    "AAEBAea5Away9wSWtwWYxAXn9QXr9QX8+QUMgJ8E1p8Es6AEqeYE0e0Eh/YEtPcE3YIFk6QF8MMF9MMF16IGAAA=",
    "AAEBAZICBIDUBPfBBargBaqeBg2JoASO1ATwzQXq0AXr0AXs0AX83wWC4AWK4AWR4AWp4AXHngbXogYAAA=",
    "AAEBAZ8FAqqKBLTmBA7JoATWoASS5ASH9gSX9gSY9gS5/wSZgQXAxAXKxAW6xwWUygXizQW0ngYAAA==",
    "AAEBAaIHArugBO7DBQ6RnwSSnwSpnwT2nwT3nwSgoATarAXBwwXfwwXnygXoygXk9QXS+AW9ngYAAA==",
    "AAEBAaoIBIvnA5egBMPQBbGeBg3q5wP5nwT9nwTCoATgrAWmwwXgwwXoxQXE0AXQ+AW/ngbAngbmngYAAA==",
    "AAEBAf0GCsGfBIKgBIOgBIWgBOegBN/CBc/GBfnGBazRBbieBgqSD62KBISfBIWfBLGfBJ3UBIGtBbnEBb/EBcjrBQAA",
    "AAEBAea5AwKxnwa7nwYOi7oDyboDvbsD5rsDusYD1cgD18gD+cgD/8gDsp8Gs58Gv58GhqYGh6YGAAA=",
    "AAEBAaoIBO/3Ar2ZA+O0A9PAAw2BBLIG7/ECtJcDxpkD+aUDt60Dua0D/q4Dqq8D0K8DgrEDguIDAAA=",
    "AAEBAQcEkvgCoIAD9YADm5QDDUuiBJ3wApvzAtH1AvT1AoP7Ap77ArP8ApeUA5qUA5KfA/+WBAAA",
    "AAEBAf0GBMnCApfTAtvpApz4Ag2KAfcEtgfECJvCAufLAvLQAvjQAojSAovhAujnArfxAtOuAwAA",
    "AAEBAaIHBLICnbQCzq4D1q4DDbQBnALtAp8DiAXUBYgHhQiGCZK2Avi9AvzBAtyWBAAA"
  ]
  @new_splendiferous_29_2_2 [
    # new decks 29.2.2 via hstopdecks
    "AAECAea5AwOBpga/sAbJsAYNAICFBIGfBIOfBLafBNSfBOygBOH4Be2fBruwBr6wBsOwBsyxBgA=",
    "AAECAZICBeC7Ap3YA63lBJzsBZ/zBQYA6LoDiZ8E2p8EoKAGiaEGAA==",
    "AAECAa0GBb6fBMGfBJbUBM/GBaSdBgmi6AOtigSEnwSFnwSGpAWm8QX7+AXjgAaM5gYA",
    "AAECAaIHA5G8Aq+2BIqoBguSnwT2nwTuoASKyQSMpAXfwwXo+gXungatpwazqQbLqQYA",
    "AAECAaoIAgCcmwMO57sChsQCjJQDxpkDr6cD27gDs+gDlfAD1bIExc4Exs4EpOsFh/sF5p4GAA==",
    "AAECAa35AwbSmQOGnQPw7QPz7QPfwgWs6QUH8e0DlpcGhJ4GwZ8Gy58Gq6AG96MGAA==",
    # new decks via no_archetype=yes
    "AAECAR8AD9YRg7kDjbsDtrsDzr4Dn+sD4Z8Ex7IE76IF6soF2PYF0fgFjpYG5JgG/qUGAAA=",
    "AAECAQcIkvgCr5EDkpcDuZkDgqUDx7YDjuYG3+YGC62RA7SRA42XA4+XA/qkA/ykA9WlA/mlA/WoA9isA9mtAwAA",
    "AAECAfHhBAAPm8gCqIEErYoEiZ8EnJ8Etp8EjboEjdEEkNQEiPYE1c4FpP8F8aUG1agGhuYGAAA="
  ]
  def whizbang_decks() do
    @original_splendiferous_decks ++ @new_splendiferous_29_2_2
  end

  def new_whizbang_decks(), do: @new_splendiferous_29_2_2

  @twist_data [
    {"Illidan Stormrage",
     "Health: 40 Passive: Fel Inside – After a friendly character Attacks, reduce the Cost of a Fel spell in your hand by (1).  Hero Power: Demon Spite – [1 Mana] +1 Attack and Lifesteal this turn.",
     [
       {2, "Grave Defiler"},
       {2, "Taste of Chaos"},
       {2, "Chaos Strike"},
       {2, "Dryscale Deputy"},
       {2, "Fel Barrage"},
       {2, "Fossil Fanatic"},
       {2, "Multi-Strike"},
       {2, "Quick Pick"},
       {2, "Coordinated Strike"},
       {2, "Disciple of Argus"},
       {2, "Herald of Chaos"},
       {2, "Sigil of Time"},
       {1, "Stargazer Luna"},
       {1, "Archmage Vargoth"},
       {2, "Demonic Assault"},
       {2, "Fan the Hammer"},
       {1, "Metamorphosis"},
       {1, "Jotun, the Eternal"},
       {1, "Queen Azshara"},
       {2, "Chaos Creation"},
       {2, "Impfestation"},
       {2, "Expendable Performers"},
       {1, "Jace Darkweaver"}
     ]},
    {"Al'Akir the Windlord",
     "Health: 35 Passive: Elemental Evocation – After you play a Legendary Elemental, call upon the power of an element.  Hero Power: OBEY MY COMMAND! – [1 Mana] Give a minion Divine Shield and Taunt.",
     [
       {1, "Elemental Evocation"},
       {1, "Devolving Missiles"},
       {1, "Elemental Allies"},
       {1, "Fire Fly"},
       {1, "Flame Geyser"},
       {1, "Kindling Elemental"},
       {1, "Synthesize"},
       {1, "Wailing Vapor"},
       {1, "Aqua Archivist"},
       {1, "Elementary Reaction"},
       {1, "Menacing Nimbus"},
       {1, "Sandstorm Elemental"},
       {1, "Sleetbreaker"},
       {1, "Spotlight"},
       {1, "Trusty Companion"},
       {1, "Arid Stormer"},
       {1, "Frostfin Chomper"},
       {1, "Gyreworm"},
       {1, "Lightning Storm"},
       {1, "Minecart Cruiser"},
       {1, "Baking Soda Volcano"},
       {1, "Dang-Blasted Elemental"},
       {1, "Al'ar"},
       {1, "Lilypad Lurker"},
       {1, "Mes'Adune the Fractured"},
       {1, "Tainted Remnant"},
       {1, "Waxadred"},
       {1, "Horn of the Windlord"},
       {1, "Baron Geddon"},
       {1, "Kalimos, Primal Lord"},
       {1, "Siamat"},
       {1, "Skarr, the Catastrophe"},
       {1, "Therazane"},
       {1, "Al'Akir the Windlord"},
       {1, "Ragnaros the Firelord"}
     ]},
    {"Arch-Villain Rafaam",
     "Health: 35 Passive: BEHOLD! My Stuff! – Your Legendary cards cost (1) less.  Hero Power: I Think I Will Take It! – [1 Mana] Discover a spell from your opponent's class that costs (3) or less.",
     [
       {1, "Ivus, the Forest Lord"},
       {1, "Sir Finley, Sea Guide"},
       {1, "Sphere of Sapience"},
       {1, "Astalor Bloodsworn"},
       {1, "Bloodmage Thalnos"},
       {1, "Flint Firearm"},
       {1, "Archdruid Naralex"},
       {1, "Brann Bronzebeard"},
       {1, "Brightwing"},
       {1, "Flightmaster Dungar"},
       {1, "Mankrik"},
       {1, "SN1P-SN4P"},
       {1, "Blademaster Okani"},
       {1, "Korrak the Bloodrager"},
       {1, "Maiev Shadowsong"},
       {1, "Pozzik, Audio Engineer"},
       {1, "Emperor Thaurissan"},
       {1, "Loatheb"},
       {1, "Moonfang"},
       {1, "Overlord Runthak"},
       {1, "Zilliax"},
       {1, "Cairne Bloodhoof"},
       {1, "Gnomelia, S.A.F.E. Pilot"},
       {1, "Sylvanas Windrunner"},
       {1, "Dr. Boom"},
       {1, "Lor'themar Theron"},
       {1, "Mutanus the Devourer"},
       {1, "Siamat"},
       {1, "Goliath, Sneed's Masterpiece"},
       {1, "Jepetto Joybuzz"},
       {1, "Ozumat"},
       {1, "Alexstrasza the Life-Binder"},
       {1, "Yogg-Saron, Unleashed"},
       {1, "Neptulon the Tidehunter"},
       {1, "Raid Boss Onyxia"}
     ]},
    {"Leeroy Jenkins",
     "Health: 40 Passive: Let's Do This! – Both players' cards cost (1) less.  Hero Power: Reckless Reinforcements – [0 Mana] The next minion you play this turn costs Health instead of Mana.",
     [
       {1, "Blessing of Wisdom"},
       {1, "First Day of School"},
       {1, "Knight of Anointment"},
       {1, "Sanguine Soldier"},
       {1, "Argent Protector"},
       {1, "Blood Matriarch Liadrin"},
       {1, "Crooked Cook"},
       {1, "For Quel'Thalas!"},
       {1, "Hand of A'dal"},
       {1, "Hi Ho Silverwing"},
       {1, "Hydrologist"},
       {1, "Knife Juggler"},
       {1, "Manafeeder Panthara"},
       {1, "Sound the Bells!"},
       {1, "Squashling"},
       {1, "Acolyte of Pain"},
       {1, "Aldor Peacekeeper"},
       {1, "Alliance Bannerman"},
       {1, "Cathedral of Atonement"},
       {1, "Consecration"},
       {1, "Disco Maul"},
       {1, "Divine Favor"},
       {1, "Funkfin"},
       {1, "Goody Two-Shields"},
       {1, "Hammer of Wrath"},
       {1, "Keeper of Uldaman"},
       {1, "Magnifying Glaive"},
       {1, "Salhet's Pride"},
       {1, "Stargazer Luna"},
       {1, "Voracious Reader"},
       {1, "Warsong Commander"},
       {1, "Wickerflame Burnbristle"},
       {1, "Ancestral Guardian"},
       {1, "Crusader Aura"},
       {1, "Keeper's Strength"}
     ]},
    {"Kael'Thas Sunstrider",
     "Health: 35 Passive: Fel Fueled – Cards that didn't start in your deck cost (1) less.  Hero Power: Unstable Magic – [Passive] At the start of your turn, get a playable spell. Discard it at end of turn.",
     [
       {1, "Arcane Wyrm"},
       {1, "Babbling Book"},
       {1, "Evocation"},
       {1, "Fire Fly"},
       {1, "First Day of School"},
       {1, "First Flame"},
       {1, "Jar Dealer"},
       {1, "Learn Draconic"},
       {1, "Magic Trick"},
       {1, "Synthesize"},
       {1, "Training Session"},
       {1, "Unstable Felbolt"},
       {1, "Violet Spellwing"},
       {1, "Wand Thief"},
       {1, "Astral Rift"},
       {1, "Dark Peddler"},
       {1, "Dryscale Deputy"},
       {1, "Expired Merchant"},
       {1, "Flint Firearm"},
       {1, "Mana Cyclone"},
       {1, "Primordial Glyph"},
       {1, "Prismatic Elemental"},
       {1, "Ram Commander"},
       {1, "Runed Orb"},
       {1, "Tiny Knight of Evil"},
       {1, "Unstable Portal"},
       {1, "Wandmaker"},
       {1, "Whelp Wrangler"},
       {1, "Arcsplitter"},
       {1, "Dark Skies"},
       {1, "Instructor Fireheart"},
       {1, "Messenger Raven"},
       {1, "Ravencaller"},
       {1, "Reckless Diretroll"},
       {1, "Trolley Problem"},
       {1, "Gloomstone Guardian"},
       {1, "Leyline Manipulator"},
       {1, "School Teacher"},
       {1, "Blast Wave"},
       {1, "Cobalt Spellkin"},
       {1, "Spawn of Deathwing"},
       {1, "Maruut Stonebinder"},
       {1, "Cho'gall"},
       {1, "Mana Giant"},
       {1, "Grand Magister Rommath"}
     ]},
    {"C'Thun",
     "Health: 35 Passive: I am Inevitable! – C'Thun starts in your hand. After two friendly minions die, give your C'Thun +1/+1.  Hero Power: C'THUN! C'THUUUN! – [1 Mana] Discover a follower of C'Thun.",
     [
       {1, "Cactus Construct"},
       {1, "Living Roots"},
       {1, "Chaotic Consumption"},
       {1, "Forest Seedlings"},
       {1, "Grimoire of Sacrifice"},
       {1, "Lingering Zombie"},
       {1, "Plague of Flames"},
       {1, "Pop-Up Book"},
       {1, "Wicked Shipment"},
       {1, "Dreamway Guardians"},
       {1, "Haunted Creeper"},
       {1, "Mining Casualties"},
       {1, "Shrubadier"},
       {1, "Thorngrowth Sentries"},
       {1, "BEEEES!!!"},
       {1, "Darkshire Councilman"},
       {1, "Frostwolf Kennels"},
       {1, "Imp Gang Boss"},
       {1, "Plot of Sin"},
       {1, "Swipe"},
       {1, "Branching Paths"},
       {1, "Klaxxi Amber-Weaver"},
       {1, "Murlocula"},
       {1, "Flipper Friends"},
       {1, "Glowfly Swarm"},
       {1, "Swarm of Lightbugs"},
       {1, "Twilight Darkmender"},
       {1, "Ancient Shieldbearer"},
       {1, "Trial by Fire"},
       {1, "Twin Emperor Vek'lor"}
     ]},
    {"Nozdormu",
     "Health: 35 Passive: It's About Time – Start with an extra Mana Crystal. You only have 30 seconds to take your turn.  Hero Power: Dragonflight – [2 Mana] Draw a Dragon. It costs (1) less.",
     [
       {1, "Arcane Breath"},
       {1, "Cleric of Scales"},
       {1, "Flight of the Bronze"},
       {1, "Giftwrapped Whelp"},
       {1, "Sand Breath"},
       {1, "Twilight Whelp"},
       {1, "Alexstrasza's Champion"},
       {1, "Breath of Dreams"},
       {1, "Corrosive Breath"},
       {1, "Dragonmaw Sentinel"},
       {1, "Firetree Witchdoctor"},
       {1, "Lay Down the Law"},
       {1, "Nether Breath"},
       {1, "Netherspite Historian"},
       {1, "Redscale Dragontamer"},
       {1, "Splish-Splash Whelp"},
       {1, "Wyrmrest Agent"},
       {1, "Amber Whelp"},
       {1, "Breath of the Infinite"},
       {1, "Consecration"},
       {1, "Dragonrider Talritha"},
       {1, "Lightbringer's Hammer"},
       {1, "Lightning Breath"},
       {1, "Timewarden"},
       {1, "Desert Nestmatron"},
       {1, "Duskbreaker"},
       {1, "Future Emissary"},
       {1, "Molten Breath"},
       {1, "Blackwing Corruptor"},
       {1, "Chronobreaker"},
       {1, "Crazed Netherwing"},
       {1, "Dragonfire Potion"},
       {1, "Malygos, Aspect of Magic"},
       {1, "Onyxian Warder"},
       {1, "Aeon Reaver"},
       {1, "Candle Breath"},
       {1, "Nithogg"},
       {1, "Anachronos"},
       {1, "Murozond, Thief of Time"},
       {1, "Deathwing, Mad Aspect"},
       {1, "Murozond the Infinite"},
       {1, "Alexstrasza the Life-Binder"},
       {1, "Fye, the Setting Sun"},
       {1, "Ysera the Dreamer"},
       {1, "Raid Boss Onyxia"}
     ]},
    {"The Lich King",
     "Health: 35 Passive: Cadaver Collector – After you spend a Corpse, summon a Risen Skeleton with stats equal to the Corpses spent.  Hero Power: Relentless Ghoul – [2 Mana] Summon a 1/1 Zombie with Reborn and Charge. It dies at end of turn.",
     [
       {2, "Arms Dealer"},
       {2, "Body Bagger"},
       {2, "Fistful of Corpses"},
       {2, "Heart Strike"},
       {2, "Lingering Zombie"},
       {2, "Plagued Grain"},
       {2, "Runes of Darkness"},
       {2, "Haunted Creeper"},
       {2, "Mining Casualties"},
       {2, "Acolyte of Death"},
       {2, "Corpse Farm"},
       {2, "Crop Rotation"},
       {2, "Eulogizer"},
       {2, "Unliving Champion"},
       {2, "Ymirjar Deathbringer"},
       {2, "Malignant Horror"},
       {1, "Sickly Grimewalker"},
       {2, "Tomb Guardians"},
       {2, "Corpse Bride"},
       {2, "Stitched Giant"},
       {1, "The Scourge"}
     ]},
    {"Xyrella",
     "Health: 30 Passive: Purify the Shard – Your max health is 60. Reach it to win the game. Damaging the enemy hero heals your hero.  Hero Power: Spark of Light – [1 Mana] Restore 2 Health. Manathirst (8): Restore 4 Health instead.",
     [
       {1, "Cleric of An'she"},
       {1, "Deafen"},
       {1, "Mistress of Mixtures"},
       {1, "Shadowtouched Kvaldir"},
       {1, "Shard of the Naaru"},
       {1, "The Light! It Burns!"},
       {1, "Astalor Bloodsworn"},
       {1, "Auchenai Phantasm"},
       {1, "City Tax"},
       {1, "Hi Ho Silverwing"},
       {1, "Hidden Gem"},
       {1, "Serena Bloodfeather"},
       {1, "Benevolent Banker"},
       {1, "Dehydrate"},
       {1, "Devouring Plague"},
       {1, "Haunting Nightmare"},
       {1, "Holy Nova"},
       {1, "Wickerflame Burnbristle"},
       {1, "Brittlebone Destroyer"},
       {1, "Fight Over Me"},
       {1, "Hysteria"},
       {1, "Ivory Knight"},
       {1, "School Teacher"},
       {1, "Xyrella"},
       {1, "Crystal Stag"},
       {1, "Mass Hysteria"},
       {1, "Raza the Chained"},
       {1, "Sandhoof Waterbearer"},
       {1, "Harmonic Pop"},
       {1, "Khartut Defender"},
       {1, "Lightshower Elemental"},
       {1, "Aman'Thul"},
       {1, "Blackwater Behemoth"},
       {1, "Blightblood Berserker"},
       {1, "Soul Mirror"}
     ]},
    {"Patches the Pirate",
     "Health: 35 Passive: Locked and Loaded – After you summon a Pirate, it deals 1 damage to a random enemy.  Hero Power: I'm in Charrrge! – [3 Mana] Draw a Pirate. Cost reduces by (1) after you play a Pirate.",
     [
       {1, "Backstab"},
       {1, "Blackwater Cutlass"},
       {1, "Bloodsail Flybooter"},
       {1, "Dig For Treasure"},
       {1, "Execute"},
       {1, "Gone Fishin'"},
       {1, "Jolly Roger"},
       {1, "Patches the Pirate"},
       {1, "Shiver Their Timbers!"},
       {1, "Sky Raider"},
       {1, "Swashburglar"},
       {1, "Amalgam of the Deep"},
       {1, "Bloodsail Raider"},
       {1, "Eviscerate"},
       {1, "Fan of Knives"},
       {1, "Fogsail Freebooter"},
       {1, "Harbor Scamp"},
       {1, "Obsidiansmith"},
       {1, "Parachute Brigand"},
       {1, "Serrated Bone Spike"},
       {1, "Toy Boat"},
       {1, "Ancharrr"},
       {1, "Bargain Bin Buccaneer"},
       {1, "Crow's Nest Lookout"},
       {1, "Defias Cannoneer"},
       {1, "Pufferfist"},
       {1, "Skybarge"},
       {1, "Swordfish"},
       {1, "Edwin, Defias Kingpin"},
       {1, "Hoard Pillager"},
       {1, "Sword Eater"},
       {1, "Bootstrap Sunkeneer"},
       {1, "Cannon Barrage"},
       {1, "Mr. Smite"},
       {1, "Pirate Admiral Hooktusk"}
     ]},
    {"Sir Finley Mrrgglton",
     "Health: 40 Passive: Scales of Justice – Your Murlocs have Rush.  Hero Power: Float Up! – [1 Mana] Draw a Murloc.",
     [
       {1, "Adaptation"},
       {1, "Embalming Ritual"},
       {1, "Grimscale Chum"},
       {1, "Grimscale Oracle"},
       {1, "Imprisoned Sungill"},
       {1, "Murloc Growfin"},
       {1, "Murloc Tidecaller"},
       {1, "Murmy"},
       {1, "Sir Finley, Sea Guide"},
       {1, "Spawnpool Forager"},
       {1, "Toxfin"},
       {1, "Unite the Murlocs"},
       {1, "Amalgam of the Deep"},
       {1, "Auctionhouse Gavel"},
       {1, "Hand of A'dal"},
       {1, "Hydrologist"},
       {1, "Lushwater Murcenary"},
       {1, "Murgur Murgurgle"},
       {1, "Primalfin Lookout"},
       {1, "Rockpool Hunter"},
       {1, "South Coast Chieftain"},
       {1, "Underbelly Angler"},
       {1, "Voidgill"},
       {1, "Bloodscent Vilefin"},
       {1, "Clownfish"},
       {1, "Coldlight Seer"},
       {1, "Consecration"},
       {1, "Cookie the Cook"},
       {1, "Murloc Warleader"},
       {1, "Nofin Can Stop Us"},
       {1, "Underlight Angling Rod"},
       {1, "Gentle Megasaur"},
       {1, "Murloc Knight"},
       {1, "Rotgill"},
       {1, "Everyfin is Awesome"}
     ]},
    {"King Krush",
     "Health: 35 Passive: King's Decree – After you cast a spell, reduce the Cost of a Beast in your hand by the spell's Cost.  Hero Power: Apex Predator – [6 Mana] +8 Attack this turn.",
     [
       {1, "Ricochet Shot"},
       {1, "Tracking"},
       {1, "Urchin Spines"},
       {1, "Wound Prey"},
       {1, "Barrel of Monkeys"},
       {1, "Bola Shot"},
       {1, "Call Pet"},
       {1, "Fetch!"},
       {1, "Grievous Bite"},
       {1, "Rapid Fire"},
       {1, "Tame Beast (Rank 1)"},
       {1, "Animal Companion"},
       {1, "Master's Call"},
       {1, "Powershot"},
       {1, "Revive Pet"},
       {1, "Shellshot"},
       {1, "Swipe"},
       {1, "Unleash the Hounds"},
       {1, "Flanking Strike"},
       {1, "Marked Shot"},
       {1, "Swamp King Dred"},
       {1, "Amani War Bear"},
       {1, "Blackwater Behemoth"},
       {1, "Colaque"},
       {1, "Druid of the Plains"},
       {1, "Hydralodon"},
       {1, "King Mosh"},
       {1, "Toyrannosaurus"},
       {1, "Winged Guardian"},
       {1, "King Krush"},
       {1, "Oondasta"},
       {1, "Trenchstalker"},
       {1, "Banjosaur"},
       {1, "Tyrantus"},
       {1, "Shirvallah, the Tiger"}
     ]},
    {"Forest Warden Omu",
     "Health: 35 Passive: Rapid Growth – After you summon a Treant, Adapt it randomly.  Hero Power: Call to the Grove – [1 Mana] Get a 2/2 Treant.",
     [
       {1, "Aquatic Form"},
       {1, "Innervate"},
       {1, "Preparation"},
       {1, "Forest Seedlings"},
       {1, "Mark of the Lotus"},
       {1, "Nature Studies"},
       {1, "Sow the Soil"},
       {1, "Witchwood Apple"},
       {1, "Lunar Eclipse"},
       {1, "Malfunction"},
       {1, "Mark of Scorn"},
       {1, "Natural Causes"},
       {1, "Fungal Fortunes"},
       {1, "Landscaping"},
       {1, "Overgrown Beanstalk"},
       {1, "Plot of Sin"},
       {1, "Soul of the Forest"},
       {1, "Fel'dorei Warband"},
       {1, "Aeroponics"},
       {1, "Arbor Up"},
       {1, "Deal with a Devil"},
       {1, "Living Mana"},
       {1, "Manufacturing Error"},
       {1, "Refreshing Spring Water"},
       {1, "Runic Carvings"},
       {1, "To My Side!"},
       {1, "Unending Swarm"},
       {1, "Drum Circle"},
       {1, "Rhok'delar"},
       {1, "Cultivation"}
     ]},
    {"Dr. Boom",
     "Health: 45 Passive: Boom Barrage – After a friendly Mech dies, shuffle a Bomb into your opponent's deck.  Hero Power: Boomspiration – [2 Mana] Summon a 1/1 Boom Bot. WARNING: Bots may explode.",
     [
       {1, "Drone Deconstructor"},
       {1, "Execute"},
       {1, "Glow-Tron"},
       {1, "Omega Assembly"},
       {1, "Trench Surveyor"},
       {1, "Amalgam of the Deep"},
       {1, "Bomb Toss"},
       {1, "From the Scrapheap"},
       {1, "Micro Mummy"},
       {1, "Noble Minibot"},
       {1, "Security Automaton"},
       {1, "Venomizer"},
       {1, "Bellowing Flames"},
       {1, "Coldlight Oracle"},
       {1, "Gorillabot A-3"},
       {1, "Mecha-Shark"},
       {1, "Mimiron, the Mastermind"},
       {1, "Powermace"},
       {1, "Seascout Operator"},
       {1, "Sky Claw"},
       {1, "SN1P-SN4P"},
       {1, "SP-3Y3-D3R"},
       {1, "Spider Bomb"},
       {1, "Ursatron"},
       {1, "Giggling Toymaker"},
       {1, "Outrider's Axe"},
       {1, "Pozzik, Audio Engineer"},
       {1, "Tiny Worldbreaker"},
       {1, "Brawl"},
       {1, "Dyn-o-matic"},
       {1, "Fireworker"},
       {1, "Zilliax"},
       {1, "Flame Behemoth"},
       {1, "Mothership"},
       {1, "V-07-TR-0N Prime"},
       {1, "Blastmaster Boom"},
       {1, "Boommaster Flark"},
       {1, "The Leviathan"},
       {1, "Gaia, the Techtonic"},
       {1, "Inventor Boom"}
     ]},
    {"Zul'jin",
     "Health: 35 Passive: Warriors of Amani – After you play a Secret, summon a 2/2 Berserker.  Hero Power: Ensnare – [2 Mana] Discover a Secret. It costs (1) less.",
     [
       {1, "Blackjack Stunner"},
       {1, "Costumed Singer"},
       {1, "Secretkeeper"},
       {1, "Arcane Flakmage"},
       {1, "Bait and Switch"},
       {1, "Bargain Bin"},
       {1, "Cat Trick"},
       {1, "Explosive Trap"},
       {1, "Freezing Trap"},
       {1, "Hidden Meaning"},
       {1, "Hydrologist"},
       {1, "Ice Trap"},
       {1, "Mad Scientist"},
       {1, "Medivh's Valet"},
       {1, "Phase Stalker"},
       {1, "Quick Shot"},
       {1, "Snipe"},
       {1, "Sword of the Fallen"},
       {1, "Wandering Monster"},
       {1, "ZOMBEEEES!!!"},
       {1, "Cloaked Huntress"},
       {1, "Commander Rhyssa"},
       {1, "Inconspicuous Rider"},
       {1, "Petting Zoo"},
       {1, "Sparkjoy Cheat"},
       {1, "Chatty Bartender"},
       {1, "Throw Glaive"},
       {1, "Apexis Smuggler"},
       {1, "Halkias"},
       {1, "Orion, Mansion Manager"},
       {1, "Professor Putricide"},
       {1, "Spring the Trap"},
       {1, "Cannonmaster Smythe"},
       {1, "Lesser Emerald Spellstone"},
       {1, "Product 9"},
       {1, "Aggramar, the Avenger"},
       {1, "Contract Conjurer"},
       {1, "Sayge, Seer of Darkmoon"},
       {1, "Starstrung Bow"},
       {1, "King Plush"}
     ]},
    {"N'Zoth, the Corruptor",
     "Health: 35 Passive: Dark Machinations – After you play a Deathrattle minion, trigger its Deathrattle.  Hero Power: Rise Again! – [2 Mana] Summon a 1/1 copy of the last Deathrattle minion you played.",
     [
       {1, "Batty Guest"},
       {1, "Call of the Grave"},
       {1, "Lingering Zombie"},
       {1, "Play Dead"},
       {1, "Unstable Felbolt"},
       {1, "Dead Ringer"},
       {1, "Defile"},
       {1, "Kindly Grandmother"},
       {1, "Loot Hoarder"},
       {1, "Museum Curator"},
       {1, "Roll the Bones"},
       {1, "Shallow Grave"},
       {1, "Starscryer"},
       {1, "Terrorscale Stalker"},
       {1, "Unstable Shadow Blast"},
       {1, "Devouring Ectoplasm"},
       {1, "Domino Effect"},
       {1, "Necrium Blade"},
       {1, "Piggyback Imp"},
       {1, "Reefwalker"},
       {1, "Voodoo Doll"},
       {1, "Ball Hog"},
       {1, "Baron Rivendare"},
       {1, "Infested Tauren"},
       {1, "Piloted Shredder"},
       {1, "Stubborn Suspect"},
       {1, "Teacher's Pet"},
       {1, "Vectus"},
       {1, "Claw Machine"},
       {1, "Ring Matron"},
       {1, "Darkmoon Tonk"},
       {1, "Enhanced Dreadlord"},
       {1, "Wretched Queen"},
       {1, "Obsidian Statue"},
       {1, "Stoneborn General"}
     ]},
    {"Brann Bronzebeard",
     "Health: 35 Passive: Brann's Saddle – After you play a Battlecry minion, transform it into a random Beast of the same cost.  Hero Power: Crack the Whip – [1 Mana] Your next Battlecry triggers twice.",
     [
       {1, "Alleycat"},
       {1, "Blazing Invocation"},
       {1, "Mystery Winner"},
       {1, "Overwhelm"},
       {1, "Shock Hopper"},
       {1, "Slam"},
       {1, "Tracking"},
       {1, "Trinket Tracker"},
       {1, "Auctionhouse Gavel"},
       {1, "Crackling Razormaw"},
       {1, "Deeprun Engineer"},
       {1, "EVIL Cable Rat"},
       {1, "Grimestreet Informant"},
       {1, "Maze Guide"},
       {1, "Novice Engineer"},
       {1, "Painted Canvasaur"},
       {1, "Shrubadier"},
       {1, "Waxmancy"},
       {1, "Brilliant Macaw"},
       {1, "Crow's Nest Lookout"},
       {1, "Fairy Tale Forest"},
       {1, "Harmonica Soloist"},
       {1, "Kobold Apprentice"},
       {1, "Sewer Crawler"},
       {1, "Stitched Tracker"},
       {1, "Crud Caretaker"},
       {1, "Fire Plume Phoenix"},
       {1, "Rattling Rascal"},
       {1, "Triplewick Trickster"},
       {1, "Bomb Squad"},
       {1, "Cattle Rustler"},
       {1, "Dyn-o-matic"},
       {1, "Former Champ"},
       {1, "Loatheb"},
       {1, "Night Elf Huntress"},
       {1, "Abyssal Summoner"},
       {1, "Entitled Customer"},
       {1, "Lord Godfrey"},
       {1, "Swampqueen Hagatha"},
       {1, "Deathwing, Mad Aspect"},
       {1, "Gigafin"},
       {1, "Jepetto Joybuzz"},
       {1, "Murozond the Infinite"},
       {1, "Tidal Revenant"},
       {1, "Alexstrasza the Life-Binder"}
     ]},
    {"Guff Runetotem",
     "Health: 35 Passive: Might of the Fang – After your Hero gains Attack, they also gain that much Armor.  Hero Power: Feral Frenzy – [1 Mana] +1 Attack this turn. Usable twice a turn.",
     [
       {1, "Aquatic Form"},
       {1, "Pounce"},
       {1, "Battlefiend"},
       {1, "Burning Heart"},
       {1, "Feast and Famine"},
       {1, "Jolly Roger"},
       {1, "Lesser Jasper Spellstone"},
       {1, "Secure the Deck"},
       {1, "Sock Puppet Slitherspear"},
       {1, "Toxic Reinforcements"},
       {1, "Battleworn Vanguard"},
       {1, "Crooked Cook"},
       {1, "Deathmatch Pavilion"},
       {1, "Felfire Deadeye"},
       {1, "Lesser Opal Spellstone"},
       {1, "Manafeeder Panthara"},
       {1, "Multi-Strike"},
       {1, "Papercraft Angel"},
       {1, "Rake"},
       {1, "Savage Striker"},
       {1, "Stoneskin Armorer"},
       {1, "Wickerclaw"},
       {1, "Defias Cannoneer"},
       {1, "Hookfist-3000"},
       {1, "Ironclad"},
       {1, "Keeneye Spotter"},
       {1, "Pufferfist"},
       {1, "Silithid Swarmer"},
       {1, "Dragonbane"},
       {1, "Glaiveshark"},
       {1, "Going Down Swinging"},
       {1, "Park Panther"},
       {1, "Sand Art Elemental"},
       {1, "Savage Combatant"},
       {1, "Shockspitter"},
       {1, "Spread the Word"},
       {1, "Captain Galvangar"},
       {1, "Khaz'goroth"},
       {1, "Confessor Paletress"},
       {1, "Frost Giant"}
     ]}
  ]
  def twist_data(), do: @twist_data

  def process_twist_data(data \\ @twist_data) do
    Enum.map(data, fn {name, comment, card_name_tuples} ->
      {errors, card_ids} = process_twist_cards(card_name_tuples)
      IO.inspect(errors, label: "#{name} errors")
      card_names = Enum.map(card_name_tuples, &elem(&1, 1))
      hero_id = get_hero_id(name)
      deckcode = Backend.Hearthstone.Deck.deckcode(card_ids, hero_id, 4)

      %{
        name: name,
        comment: comment,
        deckcode: deckcode,
        card_names: card_names
      }
    end)
  end

  def twist_deck_archetyping(unprocessed_data \\ @twist_data) do
    Enum.map_join(unprocessed_data, "\n\n", fn {name, _, card_name_tuples} ->
      min_count_part =
        card_name_tuples
        |> Enum.map(&elem(&1, 1))
        |> card_names_to_min_count(4)

      "#{min_count_part} -> :\"#{name}\""
    end)
  end

  @twist_codes [
    "AAEEAea5AwbWmQON9wPbuQSU1ATG+QWzngYRifcDgfsDrpEE8pEEgJ8Etp8EjrAEwMoEoM4EsvUFmoAGipAG65gGnJoG7p4Gq6AG9uUGAAA=",
    "AAEEAaoII7P3AsiHA8+lA8CuA/OvA+u+A+DMA4zhA+DsA+HsA63uA6/uA5WSBP2fBICgBKqgBOOgBOajBcbEBfLEBfboBbCNBsCPBsOPBtSVBvebBpidBvGdBrKeBoCfBqelBv2wBpXmBujmBu3mBgAAAA==",
    "AAEEAZ8FI6cF8QexCI8J3QrJFry9ArPBAvnsAuj5AqChA5WmA57NA/vOA8bRA8rRA8zrA/D2A5yfBOufBJzUBKviBN3tBIaDBauTBYGWBYSWBcDEBbrHBZX1BbyPBo6VBrOeBrWeBoajBgAAAA==",
    "AAEEAf0ELYkP2RXPFsCsAs3rAsXsAur2AqaHA6+NA+eVA+KbA/+dA/2kA/2lA+usA/usA/2sA/GvA4GxA8W4A72+A57NA5zOA6TRA9DsA673A6GNBMSgBP+sBJa3BKOQBcWTBaqYBauYBaWlBfLEBeSYBuuYBvGcBpugBtWiBqaoBobmBu3mBu/mBgAAAA==",
    "AAEEAZICHvUN8BGdrAK0rALYrALdrQLxrwKe0gLKnAOvogOdqQP+rQPvugOt7APX7QPFgAT2vQS4vgSB1ATL4gS14wSxmAWw+gWk+wXu/QX2lQbYnAaSoAaopwb35QYAAAA=",
    "AAEEAfHhBAKXlQbh5QYT9Q384wT/4wTV8QSy9wSYgQWZgQWSkwWxmAWDoQXPpQWv+QWDkgaUlQaRlwaAmAaSoAbT5QbW5QYAAA==",
    "AAEEAa0GI4+0AoO7Ary9At7EApeHA+uIA7ufA6GhA9GlA8i+A9bOA/jjA5rrA5vrA5/rA9TtA+jvA4f3A4v4A4SfBKi2BJa3BPnbBIaTBfigBeKkBbvEBb/EBc/2BcmABq+NBryPBvWYBsOcBpagBgAAAA==",
    "AAEEAaIHI5G8AtuMA9ytA92tA96tA7+uA+iwA+mwA7XeA5X2A5f2A72ABL+ABMmABO2ABJyBBKaKBJGfBJ+fBK2gBO6gBIqwBLezBKC2BK+2BJC3BLLBBJrbBPXdBNejBb2eBtmiBvylBq2nBsCoBgAAAA==",
    "AAEEAR8j+AjbCa4QzhSGwwKWwwLRwwLixwLd0gK9hgObigPYjAPmlgPslgP/tQON5AOa7AO+7APb7QOpnwTXowSgsASotgTBuQTnuQSwxwTB0wSJ1ASakgWo0QXS+AXqpQb6pQb35Qb+5QYAAAA=",
    "AAEEAZICHv0CzbsChsEC6dIC6uMC3/sC/K0D5boDm84DltEDieADjOQD0ewD7PUDrp8E958ErsAEst0EteMEhpIFiZIFkJIFt5gF+d8FsPoF2f8FrJ4G5aYG5bgGydAGAAAA",
    "AAEEAQco+AfUD+D1AuH1AuL1Arn4AoP7Ap77Atb+AqCAA5uUA7acA8WhA4euA5+3A47tA5+fBIigBKGxBLCyBJK1BMm3BN25BOO5BOS5BLLBBJSkBfTIBbb2Bab4Bbn6Beb6Ber6BYb+Bbn+BYWCBreZBoigBpOoBpi1BgAAAA==",
    "AAEEAR8ongGuBvcN+LECxLQC17YCs8ECw8wC39IClJoDvqQD+68DjbkD0LkDy90DleED6OEDhOIDguQDzusDgOwDqY0E458E5J8Eu6AE4NoEo+QEveQE/5IFp6QF6OgF6vIF/PgF1/kF7ZsG/qUGrLYG3LgGgOYGguYGAAAA",
    "AAEEAf0GI/sOkBC+FoCvArm0AtjCAsDMApzNArfxAt76AqH+Ave4A72+A5LNA4rSA7rhA4PiA7zjA4jvA6jvA+DxA4b3A6mRBKGgBIq3BMHjBKztBMCSBbGYBcjrBfTrBcL4Bb+wBpWzBpazBgAAAA==",
    "AAEEAR8tnAL6Duq7Apq8Avi/AqzCAo7DArbLAtPNAtHSAunmApz4Aon6Ap77AquMA7SRA7mZA9qdA+6sA/6tA46xA562A7nQA/LhA9b1A8P5A4L7A8mABNOABLCKBKmfBIagBPXHBPPOBPTcBLPdBKqkBdqsBcmRBuyVBuelBuKmBqSnBu3UBuXmBgAAAA==",
    "AAEEAZICKNAT/BPcFaCrAsCGA8aGA/mtA4WwA/vOA6zeA4DkA5DkA4D3A5yBBMmfBNKfBIqlBIqwBI6wBO+xBK7ABN3tBKiTBa6TBY2WBdejBe6jBaSlBffDBZHgBcbzBaH7Ba+eBumeBtOnBsSoBsawBte4BvjlBvzlBgAAAA==",
    "AAEEAf0GI6QD+g6eENYRhReggAPanQO3rAOftwPtvgOPzgOV5AOm7wPI7wPn8APX+QOpgQSqigSwigSXoATxpATypASlrQTlsATHsgS8zgS/zgTvogXipAX0yAWplQbkmAbx1Abn5gbo5gYAAAA=",
    "AAEEAfHhBCPt4wTw4wT04wT14wT84wSJ5gTR7QTY8QSB9gSX9gSy9wS0gAWTgQWYgQWogQXdggXLpQXNpQX4+QX8+QXt/wX3jAaDkgaIkgaLkgaRlwb/lwaSoAbpqQbLsAa5sQa7sQbY5Qbg5Qbk5QYAAAA=",
    "AAEEAZ8FI/4D3xS/F9O8ArPBAp3CArHCAobEApvEAtjHAoyUA7WYA6ylA8i4A/u4A/y4A5PoA7PoA93sA5XwA9b1A6SBBJyfBKKgBKugBOWwBPSxBLLBBMXOBO7TBP7YBPSgBbWeBtSeBtHQBgAAAA==",
    "AAEEAZ8FLe4R6RKkFMYVgrUC6r8Cy+YC6IkD3KwD5awD7KwD8qwD+qwDiq0Du60D8K0DjK4Dna4DoK4Dva4DjrED/7QDmLYDmbYD4bYDuLoD+d4D7/YDsIoEtIoEnJ8EuqwEpa0EkYkFo5MFp5MFr5MFu5UGwZUGlpYG2pwGyaEGnqIG6qgG5eYGAAAA",
    "AAEEAZICHvUNtKwCi68CzbsCoM0CypwDr6IDnakD/q0Dos4DieAD1+0Dz6wE9r0EgdQEy+IEteMEsZgFkaMFpPsF7v0Fy44G0o4G9pUGtZoG2JwGkqAGoqIGqKcG9+UGAAAA",
    "AAEEAQcoigb4B8rnAr/yAuD1AuH1Ap77Avb9AomAA4yAA5uUA8WhA4euA422A5+3A/mMBImgBKGxBLCyBJK1BMm3BN25BOO5BOS5BLLBBI7UBJDUBPfBBbb2BbX4Bbn6Beb6Ber6Bbn+BYaUBuifBoigBrmkBpOoBpi1BgAAAA==",
    "AAEEAfHhBCOTxwKYuQOW6APJ+QPcuQTt4wTw4wT04wT14wT84wSG5ASM5ATR7QSB9gSI9gS1gAWTgQWogQXNpQWUygWt9QWC+AXt/wX7gAaDkgaUlQaRlwb/lwbDnAbIoAbpqQbLsAa5sQa7sQbk5QYAAAA=",
    "AAEEAf0EMokP2RXPFsCsAs3rAsXsAur2Aq+NA+eVA/+dA/qkA/2kA/2lA9isA+usA/usA/2sA/GvA4GxA622A8W4A72+A57NA5zOA6TRA9DsA673A6GNBMSgBP+sBJa3BKOQBcWTBaqYBauYBaWlBfWpBfLEBfnGBeSYBuuYBvGcBsufBpugBtWiBqaoBrrBBobmBu3mBu/mBgAAAA==",
    "AAEEAZ8FMu4R6RKJFKQU+hTGFYK1Auq/AsvmAuiJA+iUA9ysA+WsA+ysA/KsA/qsA4qtA7utA/CtA4yuA52uA6CuA72uA46xA/+0A5i2A5m2A+G2A7i6A/neA+/2A7CKBLSKBJyfBLqsBKWtBJGJBaOTBaSTBaeTBa+TBZGkBbuVBsGVBpaWBtqcBsmhBp6iBuqoBuXmBgAAAA==",
    "AAEEAR8tngGuBvcN+LECxLQC17YCs8ECw8wC39IClJoDvqQD+68DjbkD0LkD2dEDy90DleED6OEDhOIDguQDzusDgOwDqY0E458E5J8Eu6AE3NAE4NoEo+QEveQE/uwEzJIF/5IFp6QF2qwF6OgF6vIF/PgF1/kF7ZsG/qUGrLYG3LgGgOYGguYGAAAA",
    "AAEEAaoIKOauAtXBArP3AsqHA8+lA8CuA/OvA+u+A+DMA4zhA+DsA+HsA63uA6/uA5WSBP2fBICgBKqgBOOgBL/OBKqYBcbEBfLEBfboBbH+BbCNBsCPBsOPBtSVBvGbBvWbBvebBpidBvGdBrKeBoCfBqelBpXmBujmBu3mBgAAAA==",
    "AAEEAR8j5AiGwwKWwwLd0gK9hgObigP/tQPougOTwgObzgOa7AOpnwTXowTlpASgsASotgTYtgTptgTnuQSOyQS8zgTB0wSJ1ATW3gSo0QXz8gXS+AWlgQbWmAbYnAaJoQbqpQb+pQb35Qb+5QYAAAA=",
    "AAEEAea5AwiZ+wLWmQPR3QON9wPbuQSU1ATG+QWzngYQifcDgfsDrpEE8pEEgJ8Etp8EjrAEwMoE9MMFsvUFipAG65gGnJoG7p4Gq6AG9uUGAAA=",
    "AAEEAf0GI/sOxw++FuCsArm0AsDMApzNAvnmAt76AoWtA72+A5LNA7TOA/jWA4PiA4jvA+DxA4b3A4f9A6GgBNGgBOWkBPKkBOO5BMHjBMCSBbGYBeyjBcjrBfTrBZqABviCBpGeBpWzBpK4BgAAAA==",
    "AAEEAZ8FI+UE8QexCI8JyRbOswK8vQKzwQL57ALo+QKgoQOVpgOezQP7zgPG0QPK0QPM6wOV7QPw9gOcnwTrnwSc1ASr4gTd7QSGgwWBlgWElgXAxAW6xwWV9QW8jwaOlQaznga1ngaGowYAAAA=",
    "AAEEAZICI/0Cig7NuwKGwQLp0gLq4wLf+wL8rQPlugObzgOW0QPw1AOJ4AOM5APR7APs9QOunwSy3QTW3gS14wSt5QSGkgWJkgWQkgW3mAX53wXN7gXK+AWw+gXZ/wWsngblpgazpwbluAbJ0AYAAAA=",
    "AAEEAR8jnAL4vwK2ywLTzQLR0gLp5gKc+AKe+wLZ/gKrjAO5mQPurAP+rQOOsQOetgO50APW9QOC+wPJgATTgASwigSpnwSGoAT1xwTzzgT03ASz3QSu7wSqmAWqpAWNgwbslQbipgakpwbt1AYAAAA=",
    "AAEEAZICI5EP/BPcFcaGA/mtA4WwA9XUA5DkA4D3A5yBBISNBPaPBMmfBNKfBIqlBI6wBN3tBKiTBa6TBY2WBdejBe6jBffDBZHgBfboBcbzBaH7BY2QBq+eBumeBtOnBsawBte4BvjlBvzlBgAAAA==",
    "AAEEAfHhBB6vogP84wT/4wSQ5ASR5ATV8QSy9wSYgQWZgQXdggWSkwWxmAWDoQXPpQWYxAWv+QWDkgaLkgaUlQaXlQaYlQaRlwaAmAaSoAb/pQbT5QbW5QbY5Qbg5Qbh5QYAAAA=",
    "AAEEAZ8FI/4D3xS/F7PBAp3CArHCAobEApvEAtjHAoyUA7SXA7WYA/y4A5PoA7PoA93sA5XwA9b1A5yfBK6fBKKgBKugBOWwBPSxBIC1BK7ABLLBBMXOBO7TBP7YBPSgBcOkBbWeBtCpBtHQBgAAAA==",
    "AAEEAf0GHo4OrRDPFvLQApfTAp3iAujnAoPHA/TOA7zjA/7tA4H7A4P7A6+SBLSSBN2TBLGfBNSfBJ3UBOCkBfHGBcjrBcL4Bej/BYWOBo+oBpSzBpazBoq1BpzBBgAAAA==",
    "AAEEAaIHLYwCsgKlCc8W9bsCgMICgsICjcMCvq4DubgDm80Dns0Dx84DitAD390D8d0D890DleADheQDnfADofQDsvcDkZ8E9Z8E958E3qQE9d0EpeIExuIErNEFkekFxfkFpPoFkIMGuYYGr40GvpUGjZYGvZ4GwKgGqrEGkLQGl7gG9OUG7+YGAAAA",
    "AAEEAZ8FMsIO1xPeFPnAAtrFArnHAr/lArb7AsSJA9KJA5mUA6K2A5u6A6+6A92+A6fLA7/RA8DRA8PRA+DRA/voA9r2A6D3A434A8X7A7aABJyfBNGgBPSkBPmkBNCsBOq4BNO9BPPbBPTbBKHiBPvuBIyDBauTBYOWBYSWBbvHBc6OBryPBoCVBo6VBrWeBofmBojmBonmBgAAAA==",
    "AAEEAf0EKJ+bA9DsA52wBO2xBImyBI2yBNiyBLezBKS2BKW2BJa3BNu5BNy5BOC5BOG5BI26BJi6BPi9BPC/BPu/BK7ABLLBBIbJBMDTBKneBJCWBejKBaT/BciPBomQBo2QBpGQBoOVBuuYBpCeBrKeBsigBvTlBobmBtfzBgAAAA==",
    "AAEEAf0GKK0Q+BHexALwzwLF8wKggAOPggOohwOhoQObzQOY6gOb6wPY7APY7QPy7QOI7wP08QOK9wOD+wPEgATnoATErASO4wTOkgXgpAXipAW5xAX1+AX7+AX6+QXO+gWhkgaDlQaLlQaWoAbEqAbFqAa/sAbzuAbw5gYAAAA=",
    "AAEEAa0GKN0E9galCYcOk0estAKlwgKvwgLFxwKHlQOumwOCnQPanQP7pAPI4QPB+QPY+QOsigSLowSNtQSjtgS4tgT1xwT02wS+3ASN7wTU8QTfwwW5xAW/xAXt/QXo/wXJgAbBlAacngbOngaOqQacswaTuAbmzwYAAAA=",
    "AAEEAaoIMoEEvgbRE7IUtRTKFvaqAtHmAvaKA8aZA52jA9qlA+alA/mlA7WtA5a5A5bRA6bRA/DUA4rkA/2fBMKsBPq0BLLBBIbUBKrZBLbcBL3lBMTlBLbtBPGRBeyjBb7QBfHoBd7pBcbzBY31BZf2Bc/2BcL5Bdf5BaL6Ber6BYf7BY3+BeyVBpyeBsGeBuaeBumhBgAAAA==",
    "AAEEAQcts7sCh78CpKQDqKQD260Dzb4Dm9gDtd4D9N8DuewDwuwDmO0DiPQD8PYDlJUEn58EiKAEhaMEh7cE9NsEkpIFxJIFgq0FrcMFr8MF4s0FqOAFsOkF8OwF8/IFr/8FyYAG3o0G344GuZEGjpUG+JUGtJ4GhaAGs6EGv6IGz6UGkagG7rgG1+UGAAAA",
    "AAEEAea5AyPMugOczgPI3QPN3QOc7gPR9wPT9wOZ+QPIgATtgASmlQSzoAS0oATsoASPkgWUkgWkkgWPpQWkwwX0wwWO6QXh+AXMjgaHkAaPkAa8kQbIlAbWmAbkmAbDnAazngbungaYoAbsvAb05QYAAAA="
  ]
  def deckcodes_to_twist_archetypes(deckcodes \\ @twist_codes) do
    deckcodes
    |> Enum.map(&Backend.Hearthstone.Deck.decode!/1)
    |> decks_to_twist_archetypes()
  end

  def decks_to_twist_archetypes(decks) do
    Enum.map(decks, fn %{hero: h} = d ->
      deck_name =
        with "Metamorphosis" <- Backend.Hearthstone.get_card(h).name, do: "Ilidan Stormrage"

      card_name_tuples =
        d.cards
        |> Enum.map(&Backend.Hearthstone.get_card(&1).name)
        |> Enum.frequencies()
        |> Enum.map(fn {name, freq} -> {freq, name} end)

      {deck_name, deck_name, card_name_tuples}
    end)
    |> twist_deck_archetyping()
  end

  def tiwst_codes(), do: @twist_codes

  def card_names_to_min_count(names, leeway \\ 0) do
    uniq_names = Enum.uniq(names)
    card_names_part = Enum.map_join(uniq_names, ", ", &"\"#{&1}\"")

    """
    min_count?(card_info, #{Enum.count(uniq_names) - leeway}, [#{card_names_part}])
    """
  end

  def process_twist_cards(cards) do
    Enum.reduce(cards, {[], []}, fn {count, name}, {errors, carry} ->
      case get_card_by_name(name) do
        {:ok, %{id: id}} ->
          {errors, Enum.reduce(1..count, carry, fn _, carry -> [id | carry] end)}

        _ ->
          {[name | errors], carry}
      end
    end)
  end

  # illidan uses meta
  def get_hero_id("Illidan Stormrage"), do: 56899

  def get_hero_id(name) do
    {:ok, %{id: id}} = get_card_by_name(name)
    id
  end

  def get_card_by_name(name) do
    base_criteria = [
      {"order_by", {:desc, :collectible}},
      {"order_by", "latest"},
      Backend.Hearthstone.not_classic_card_criteria(),
      {"limit", 1}
    ]

    case Backend.Hearthstone.cards([{"name", name} | base_criteria]) do
      [%{id: id} = card] when is_integer(id) -> {:ok, card}
      _ -> {:error, name}
    end
  end

  def generate_games_for_decks(decks, user \\ nil, generate_card_stats? \\ true) do
    if Mix.env() == :dev do
      user = with nil <- user, do: Backend.UserManager.get_user(1)

      for d <- decks,
          class = Deck.class(d),
          deckcode = Deck.deckcode(d),
          format = d.format || 2,
          c <- Deck.classes(),
          _num <- 1..Enum.random(1..200) do
        dto =
          Hearthstone.DeckTracker.GameDto.from_raw_map(
            %{
              "player" => %{
                "battletag" => user.battletag,
                "class" => class,
                "deckcode" => deckcode
              },
              "opponent" => %{
                "battletag" => Ecto.UUID.generate(),
                "class" => c
              },
              "game_type" => 7,
              "format" => format,
              "player_rank" => 51,
              "player_legend_rank" => 69,
              "source" => "Self Report",
              "source_version" => "0",
              "game_id" => Ecto.UUID.generate(),
              "coin" => Enum.random([true, false]),
              "result" => Enum.random(["WIN", "LOSS"])
            },
            nil
          )

        {:ok, game} = DeckTracker.handle_game(dto)

        if generate_card_stats? do
          generate_false_card_stats(game)
        else
          game
        end
      end
    else
      IO.puts("NO GENERATING GAMES IN PROD")
    end
  end
end
