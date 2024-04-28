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
end
