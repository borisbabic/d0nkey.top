defmodule BackendWeb.DeveloperStreamingControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Hearthstone.Deck
  alias Backend.Repo
  alias Backend.Streaming.Streamer
  alias Backend.Streaming.StreamerDeck
  alias Hearthstone.Enums.BnetGameType

  setup %{conn: conn} do
    user = create_temp_user()
    {:ok, %{token: token}} = Backend.Api.create_developer_api_key(user)

    {:ok, conn: put_req_header(conn, "x-api-key", token)}
  end

  test "lists streamers with aggregate stats", %{conn: conn} do
    insert_streamer_deck_fixture()

    conn = get(conn, "/api/v1/streamers?search=api_streamer")

    assert %{
             "data" => %{
               "streamers" => [
                 %{
                   "login" => "api_streamer",
                   "stats" => %{
                     "deck_count" => 1,
                     "recorded_games" => 4,
                     "wins" => 3,
                     "losses" => 1,
                     "winrate" => 0.75
                   }
                 }
               ]
             }
           } = json_response(conn, 200)
  end

  test "lists every recorded deck for one streamer", %{conn: conn} do
    insert_streamer_deck_fixture()

    conn = get(conn, "/api/v1/streamers/API_STREAMER/decks?format=2")

    assert %{
             "data" => %{
               "streamer_decks" => [
                 %{
                   "streamer" => %{"login" => "api_streamer"},
                   "deck" => %{"deckcode" => "api-streamer-deck", "format" => %{"id" => 2}},
                   "performance" => %{
                     "minutes_played" => 90,
                     "wins" => 3,
                     "losses" => 1,
                     "winrate" => 0.75
                   },
                   "ranks" => %{
                     "best_legend" => 120,
                     "latest_legend" => 180,
                     "worst_legend" => 400
                   }
                 }
               ]
             }
           } = json_response(conn, 200)
  end

  test "uses HSReplay Twitch fields when direct Twitch fields are unavailable", %{conn: conn} do
    insert_streamer_deck_fixture(%{
      twitch_login: nil,
      twitch_display: nil,
      hsreplay_twitch_login: "fallback_streamer",
      hsreplay_twitch_display: "Fallback Streamer"
    })

    conn = get(conn, "/api/v1/streamers?search=FALLBACK_STREAMER")

    assert %{
             "data" => %{
               "streamers" => [
                 %{"login" => "fallback_streamer", "display_name" => "Fallback Streamer"}
               ]
             }
           } = json_response(conn, 200)
  end

  test "rejects invalid streamer deck filters", %{conn: conn} do
    conn = get(conn, "/api/v1/streamer-decks?class=INVALID")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "class"
             }
           } = json_response(conn, 400)
  end

  defp insert_streamer_deck_fixture(streamer_attrs \\ %{}) do
    streamer =
      %{
        twitch_id: System.unique_integer([:positive]),
        twitch_login: "api_streamer",
        twitch_display: "API Streamer"
      }
      |> Map.merge(streamer_attrs)
      |> then(&struct!(Streamer, &1))
      |> Repo.insert!()

    deck =
      Repo.insert!(%Deck{
        cards: [1, 1, 2],
        deckcode: "api-streamer-deck",
        format: 2,
        hero: 637,
        class: "MAGE",
        archetype: "Test Mage",
        cost: 1600
      })

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Repo.insert!(%StreamerDeck{
      streamer_id: streamer.id,
      deck_id: deck.id,
      best_rank: 1,
      best_legend_rank: 120,
      latest_legend_rank: 180,
      worst_legend_rank: 400,
      first_played: now,
      last_played: now,
      minutes_played: 90,
      wins: 3,
      losses: 1,
      game_type: BnetGameType.ranked_standard()
    })
  end
end
