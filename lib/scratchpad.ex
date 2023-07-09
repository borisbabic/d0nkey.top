defmodule ScratchPad do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
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
end
