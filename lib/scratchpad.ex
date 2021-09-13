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
end
