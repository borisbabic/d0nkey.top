defmodule Backend.Battlefy.Communicator do
  alias Backend.Blizzard
  alias Backend.Battlefy
  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Standings
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchDeckstrings

  @type qualifier :: %{
          name: String.t() | nil,
          start_time: NaiveDateTime.t(),
          slug: String.t(),
          region: String.t(),
          id: String.t()
        }
  @callback get_masters_qualifiers() :: [qualifier]
  @callback get_masters_qualifiers(NaiveDateTime.t(), NaiveDateTime.t()) :: [qualifier]

  @type invited_player :: %{
          battletag_full: String.t(),
          reason: String.t(),
          type: String.t(),
          tour_stop: String.t(),
          upstream_time: NaiveDateTime.t(),
          tournament_slug: String.t() | nil,
          tournament_id: String.t() | nil
        }
  @callback get_invited_players(Blizzard.tour_stop() | nil | String.t()) :: [invited_player]

  @callback get_tournament(Battlefy.tournament_id()) :: Tournament.t()
  @callback get_standings(Battlefy.stage_id()) :: [Standings.t()]
  @callback get_matches(Battlefy.stage_id(), Battlefy.get_matches_options()) :: [Match.t()]
  @callback get_match_deckstrings(Battlefy.tournament_id(), Battlefy.match_id()) :: [
              MatchDeckstrings.t()
            ]
end
