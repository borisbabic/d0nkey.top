defmodule Hearthstone.Leaderboards.ResponseTest do
  use ExUnit.Case, async: true

  alias Hearthstone.Leaderboards.Response
  alias Hearthstone.Leaderboards.Response.SeasonMetadata
  alias Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata
  alias Hearthstone.Leaderboards.Response.SeasonMetadata.SeasonItem
  alias Hearthstone.Leaderboards.Season

  describe "SeasonMetadata parsing" do
    test "parses complete Blizzard API raw response correctly" do
      raw_json = %{
        "region" => "EU",
        "seasonId" => 19,
        "leaderboard" => %{
          "columns" => ["rank", "accountid", "rating"],
          "rows" => [
            %{"accountid" => "Player#1234", "rank" => 1, "rating" => 10_000}
          ],
          "pagination" => %{
            "totalPages" => 10,
            "totalSize" => 250
          }
        },
        "seasonMetaData" => %{
          "EU" => %{
            "battlegrounds" => %{
              "name" => "battlegrounds",
              "ratingId" => 50,
              "seasons" => [
                %{
                  "season_id" => 19,
                  "display_name" => %{
                    "en_US" => "Season 14",
                    "de_DE" => "Saison 14"
                  }
                },
                %{
                  "season_id" => 18,
                  "display_name" => %{
                    "en_US" => "Season 13"
                  }
                }
              ]
            },
            "battlegroundsduo" => %{
              "name" => "battlegroundsduo",
              "ratingId" => 65,
              "seasons" => [
                %{
                  "season_id" => 19,
                  "display_name" => %{
                    "en_US" => "Season 14"
                  }
                }
              ]
            },
            "arena" => %{
              "name" => "arena",
              "ratingId" => 3,
              "seasons" => [
                %{"season_id" => 56},
                %{"season_id" => 55}
              ]
            },
            "undergroundarena" => %{
              "name" => "undergroundarena",
              "ratingId" => 73,
              "seasons" => [
                %{"season_id" => 8},
                %{"season_id" => 7}
              ]
            }
          },
          "US" => %{},
          "AP" => %{}
        }
      }

      assert {:ok, %Response{} = response} =
               Response.from_raw_map(raw_json, %Season{region: "EU", leaderboard_id: "battlegrounds"})

      assert response.season.season_id == 19
      assert response.season.region == "EU"
      assert response.season.leaderboard_id == "battlegrounds"

      assert {:ok, 10} = Response.total_pages(response)
      assert {:ok, 250} = Response.total_size(response)

      assert %SeasonMetadata{} = sm = response.season_metadata

      assert {:ok, %LeaderboardMetadata{} = bg_meta} =
               SeasonMetadata.get_leaderboard_metadata(sm, "battlegrounds", "EU")

      assert {:ok, 19} = LeaderboardMetadata.get_max_season_id(bg_meta)

      seasons = LeaderboardMetadata.get_seasons(bg_meta)
      assert seasons == [{"Season 14", 19}, {"Season 13", 18}]

      # Test German locale
      de_seasons = LeaderboardMetadata.get_seasons(bg_meta, "de_DE")
      assert de_seasons == [{"Saison 14", 19}, {"Season 13", 18}]

      # Arena metadata (no display_name, fallback to Season #{id})
      assert {:ok, %LeaderboardMetadata{} = arena_meta} =
               SeasonMetadata.get_leaderboard_metadata(sm, "arena", "EU")

      assert LeaderboardMetadata.get_seasons(arena_meta) == [{"Season 56", 56}, {"Season 55", 55}]

      # Underground Arena
      assert {:ok, %LeaderboardMetadata{} = ug_meta} =
               SeasonMetadata.get_leaderboard_metadata(sm, "undergroundarena", "EU")

      assert LeaderboardMetadata.get_seasons(ug_meta) == [{"Season 8", 8}, {"Season 7", 7}]
    end

    test "handles integers in seasons list gracefully" do
      meta =
        LeaderboardMetadata.from_raw_map(%{
          "name" => "standard",
          "seasons" => [122, 121, 120]
        })

      assert {:ok, 122} = LeaderboardMetadata.get_max_season_id(meta)

      assert LeaderboardMetadata.get_seasons(meta) == [
               {"Season 122", 122},
               {"Season 121", 121},
               {"Season 120", 120}
             ]
    end
  end

  describe "SeasonItem" do
    test "formats display name correctly" do
      item_with_map =
        SeasonItem.from_raw(%{
          "season_id" => 19,
          "display_name" => %{"en_US" => "Season 14", "es_ES" => "Temporada 14"}
        })

      assert SeasonItem.display_name(item_with_map, "en_US") == "Season 14"
      assert SeasonItem.display_name(item_with_map, "es_ES") == "Temporada 14"
      assert SeasonItem.display_name(item_with_map, "unknown") == "Season 14"

      item_without_dn = SeasonItem.from_raw(%{"season_id" => 8})
      assert SeasonItem.display_name(item_without_dn, "en_US") == "Season 8"

      item_from_int = SeasonItem.from_raw(56)
      assert SeasonItem.display_name(item_from_int, "en_US") == "Season 56"
    end
  end
end
