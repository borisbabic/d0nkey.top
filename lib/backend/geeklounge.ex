defmodule Backend.GeekLounge do
  @moduledoc "hearthstone.geeklounge.com"
  alias GeekLounge.Hearthstone.Tournament
  alias GeekLounge.Hearthstone.Api
  @tournament_source "geeklounge"

  @type lineup_opt ::
          {:lineup_tournament_source, String.t()}
          | {:lineupt_tournament_id, String.t()}
          | {:display_name_fun, fun()}

  @type lineup_opts :: [lineup_opt]

  def fetch_tournament(tournament_url_or_id) do
    tournament_url_or_id
    |> id()
    |> Api.fetch_tournament()
  end

  def save_worlds_2025(tournament_url_or_id \\ "mj0hm2uc-5n59pn3") do
    display_name_fun = fn _, name ->
      %{
        "Definition#31238" => "Group A - Definition",
        "FormerChamp#2973" => "Group A - PocketTrain",
        "Tansoku#1289" => "Group A - Tansoku",
        "XiaoT#4444" => "Group A - XiaoT",
        "iNS4NE#21840" => "Group B - iN4SNE",
        "Soyorin#3903" => "Group B - Soyorin",
        "mlYanming#2222" => "Group B - mlYanming",
        "che0nsu#3213" => "Group B - Che0nsu",
        "Gaby59#21292" => "Group C - Gaby59",
        "LoveStorm#1111" => "Group C - LoveStorm",
        "gyu#31470" => "Group C - gyu",
        "FilFeel#2705" => "Group C - FilFeel",
        "Tianming#3333" => "Group D - Tianming",
        "Maxiebon1234#1738" => "Group D - Maxiebon1234",
        "Furyhunter#21452" => "Group D - Furyhunter",
        "Incurro#21488" => "Group D - Incurro"
      }
      |> Map.get(name)
    end

    tournament_source = "hsesports"
    tournament_id = "worlds-2025"

    save_tournament_lineups(tournament_url_or_id,
      lineup_tournament_source: tournament_source,
      lineup_tournament_id: tournament_id,
      display_name_fun: display_name_fun
    )
  end

  @spec save_tournament_lineups(tournament_url_or_id :: String.t(), opts :: lineup_opts()) ::
          {:ok, {String.t(), String.t()}}
  def save_tournament_lineups(
        tournament_url_or_id,
        opts \\ []
      )

  def save_tournament_lineups(tournament_url_or_id, opts)
      when is_binary(tournament_url_or_id) do
    with {:ok, tournament} <- fetch_tournament(tournament_url_or_id) do
      save_tournament_lineups(tournament, opts)
    end
  end

  def save_tournament_lineups(%Tournament{} = tournament, opts) do
    tournament_id = tournament.id
    lineup_tournament_source = Keyword.get(opts, :lineup_tournament_source, @tournament_source)
    lineup_tournament_id = Keyword.get(opts, :lineup_tournament_id, tournament_id)

    base_attrs = %{
      tournament_source: lineup_tournament_source,
      tournament_id: lineup_tournament_id
    }

    display_name_fun = Keyword.get(opts, :display_name_fun, fn -> nil end)

    player_ids_and_btags =
      Enum.map(tournament.participants, &{&1.player.id, &1.player.battletag})

    for {player_id, battletag} <- player_ids_and_btags,
        {:ok, participant} <- [Api.fetch_participant(tournament_id, player_id)],
        deck_strings = Enum.map(participant.decks, & &1.deck_string),
        Enum.any?(deck_strings) do
      name = battletag || player_id
      display_name = display_name_fun.(participant, name)

      base_attrs
      |> Map.put(:name, name)
      |> Map.put(:display_name, display_name)
      |> Backend.Hearthstone.get_or_create_lineup(deck_strings)
    end

    {:ok, {lineup_tournament_source, lineup_tournament_id}}
  end

  def id(%Tournament{id: id}), do: id

  def id(tournament_url_or_id) when is_binary(tournament_url_or_id) do
    case extract_id(tournament_url_or_id) do
      {:ok, id} -> id
      _ -> tournament_url_or_id
    end
  end

  def extract_id(tournament_url) do
    uri = URI.parse(tournament_url)

    case String.split(uri.path || "", "/") do
      ["", "tournaments", tournament_id | _] -> {:ok, tournament_id}
      ["", "api", "v1", "tournaments", tournament_id | _] -> {:ok, tournament_id}
      _ -> {:error, :cant_extract_id_from_url}
    end
  end
end
