defmodule BackendWeb.DeveloperStatsControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Hearthstone.Deck
  alias Backend.Repo

  @aggregate_table "dt_past_30_days_2_aggregated_stats"

  setup %{conn: conn} do
    user = create_temp_user()
    {:ok, %{token: token}} = Backend.Api.create_developer_api_key(user)
    {:ok, conn: put_req_header(conn, "x-api-key", token)}
  end

  test "requires an API key" do
    conn = get(build_conn(), "/api/v1/meta")

    assert conn.status == 401
    assert %{"error" => %{"code" => "invalid_api_key"}} = json_response(conn, 401)
  end

  test "rejects unsupported meta parameters", %{conn: conn} do
    conn = get(conn, "/api/v1/meta?force_fresh=yes")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "force_fresh"
             }
           } = json_response(conn, 400)
  end

  test "rejects non-public archetype parameters", %{conn: conn} do
    conn = get(conn, "/api/v1/archetypes/Control%20Priest?region[]=EU")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "region"
             }
           } = json_response(conn, 400)
  end

  test "rejects unsupported deck parameters", %{conn: conn} do
    conn = get(conn, "/api/v1/decks?force_fresh=yes")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "force_fresh"
             }
           } = json_response(conn, 400)
  end

  test "rejects deck integers outside the database range", %{conn: conn} do
    conn = get(conn, "/api/v1/decks?min_games=2147483648")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "min_games"
             }
           } = json_response(conn, 400)
  end

  test "validates Standard and Wild archetype catalog formats", %{conn: conn} do
    conn = get(conn, "/api/v1/archetypes?format=twist")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "format"
             }
           } = json_response(conn, 400)
  end

  test "validates meta format before querying aggregates", %{conn: conn} do
    conn = get(conn, "/api/v1/meta?format=4")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "format"
             }
           } = json_response(conn, 400)
  end

  test "validates public rank slugs", %{conn: conn} do
    conn = get(conn, "/api/v1/meta?rank=not-a-rank")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "rank"
             }
           } = json_response(conn, 400)
  end

  test "validates public period slugs", %{conn: conn} do
    conn = get(conn, "/api/v1/meta?period=not-a-period")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "period"
             }
           } = json_response(conn, 400)
  end

  test "rejects malformed deck class collections without crashing", %{conn: conn} do
    conn = get(conn, "/api/v1/decks?player_class[MAGE]=true")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "player_class"
             }
           } = json_response(conn, 400)
  end

  test "rejects any combined with specific opponent classes", %{conn: conn} do
    conn = get(conn, "/api/v1/meta?opponent_class[]=any&opponent_class[]=MAGE")

    assert %{
             "error" => %{
               "code" => "invalid_parameter",
               "parameter" => "opponent_class"
             }
           } = json_response(conn, 400)
  end

  test "returns public meta aggregates", %{conn: conn} do
    create_aggregate_table()
    insert_aggregate_row(nil, "Test Mage", "any")

    conn =
      get(
        conn,
        "/api/v1/meta?format=2&period=past_30_days&rank=legend&min_games=1000"
      )

    assert %{
             "data" => %{
               "total_games" => 2000,
               "archetypes" => [
                 %{
                   "archetype" => "Test Mage",
                   "games" => 2000,
                   "wins" => 1200,
                   "losses" => 800,
                   "winrate" => 0.6,
                   "popularity" => 1.0
                 }
               ]
             }
           } = json_response(conn, 200)
  end

  test "returns archetype stats when card stats are not yet populated", %{conn: conn} do
    create_aggregate_table()
    insert_aggregate_row(nil, "Test Mage", "any")
    insert_aggregate_row(nil, "Test Mage", "MAGE", 300, 200)

    conn =
      get(
        conn,
        "/api/v1/archetypes/Test%20Mage?format=2&period=past_30_days&rank=legend"
      )

    assert %{
             "data" => %{
               "archetype" => "Test Mage",
               "stats" => %{"games" => 2000, "winrate" => 0.6},
               "cards" => [],
               "matchups" => [
                 %{"opponent_class" => "MAGE", "games" => 500, "winrate" => 0.6}
               ]
             }
           } = json_response(conn, 200)
  end

  test "returns newest public decks with a stable response shape", %{conn: conn} do
    create_aggregate_table()

    deck =
      Repo.insert!(%Deck{
        cards: [1, 1, 2],
        deckcode: "developer-api-deck",
        format: 2,
        hero: 637,
        class: "MAGE",
        archetype: "Test Mage",
        cost: 1600
      })

    insert_aggregate_row(deck.id, "any", "any")

    conn =
      get(
        conn,
        "/api/v1/decks?format=2&period=past_30_days&rank=legend&min_games=50"
      )

    assert %{
             "data" => %{
               "decks" => [
                 %{
                   "id" => deck_id,
                   "deckcode" => "developer-api-deck",
                   "class" => "MAGE",
                   "archetype" => "Test Mage",
                   "url" => url,
                   "stats" => %{"games" => 2000, "winrate" => 0.6}
                 }
               ],
               "pagination" => %{"limit" => 20, "next_cursor" => nil}
             }
           } = json_response(conn, 200)

    assert deck_id == deck.id
    assert url == "https://www.hsguru.com/deck/#{deck.id}"
  end

  test "paginates newest decks without returning duplicates", %{conn: conn} do
    create_aggregate_table()

    older =
      Repo.insert!(%Deck{
        cards: [1, 2],
        deckcode: "older-developer-api-deck",
        format: 2,
        hero: 637,
        class: "MAGE",
        archetype: "Test Mage",
        cost: 1200,
        inserted_at: ~N[2026-07-21 12:00:00],
        updated_at: ~N[2026-07-21 12:00:00]
      })

    newer =
      Repo.insert!(%Deck{
        cards: [3, 4],
        deckcode: "newer-developer-api-deck",
        format: 2,
        hero: 637,
        class: "MAGE",
        archetype: "Test Mage",
        cost: 1400,
        inserted_at: ~N[2026-07-22 12:00:00],
        updated_at: ~N[2026-07-22 12:00:00]
      })

    insert_aggregate_row(older.id, "any", "any")
    insert_aggregate_row(newer.id, "any", "any")

    first_page =
      conn
      |> get("/api/v1/decks?format=2&period=past_30_days&rank=legend&min_games=50&limit=1")
      |> json_response(200)

    assert %{
             "data" => %{
               "decks" => [%{"id" => first_id}],
               "pagination" => %{"next_cursor" => cursor}
             }
           } = first_page

    assert first_id == newer.id
    assert is_binary(cursor)

    second_page =
      conn
      |> get(
        "/api/v1/decks?format=2&period=past_30_days&rank=legend&min_games=50&limit=1&cursor=#{URI.encode_www_form(cursor)}"
      )
      |> json_response(200)

    assert %{
             "data" => %{
               "decks" => [%{"id" => second_id}],
               "pagination" => %{"next_cursor" => nil}
             }
           } = second_page

    assert second_id == older.id
  end

  defp create_aggregate_table do
    Repo.query!("""
    CREATE TABLE IF NOT EXISTS #{@aggregate_table} (
      id bigserial PRIMARY KEY,
      deck_id integer,
      rank varchar,
      opponent_class varchar,
      archetype varchar,
      format integer,
      winrate double precision,
      wins integer,
      losses integer,
      total integer,
      turns double precision,
      duration double precision,
      climbing_speed double precision,
      player_has_coin boolean,
      card_stats jsonb
    )
    """)

    timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    Repo.query!("COMMENT ON TABLE #{@aggregate_table} IS '#{timestamp}'")
  end

  defp insert_aggregate_row(deck_id, archetype, opponent_class, wins \\ 1200, losses \\ 800) do
    total = wins + losses

    Repo.query!(
      """
      INSERT INTO #{@aggregate_table} (
        deck_id, rank, opponent_class, archetype, format, winrate, wins, losses,
        total, turns, duration, climbing_speed, player_has_coin, card_stats
      ) VALUES (
        $1, 'legend', $2, $3, 2, $4, $5, $6, $7, 8.5, 600.0, 2.1, NULL, NULL
      )
      """,
      [deck_id, opponent_class, archetype, wins / total, wins, losses, total]
    )
  end
end
