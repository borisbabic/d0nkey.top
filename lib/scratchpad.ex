defmodule ScratchPad do
  @moduledoc false
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

    to_encode =
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
end
