defmodule Backend.Battlefy.Communicator do
  @moduledoc false
  alias Backend.Blizzard
  alias Backend.Battlefy
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchDeckstrings
  alias Backend.Battlefy.Profile
  alias Backend.Battlefy.Stage
  alias Backend.Battlefy.Standings
  alias Backend.Battlefy.Tournament

  @type signup_options :: %{
          tournament_id: Battlefy.tournament_id(),
          user_id: Battlefy.user_id(),
          token: String.t(),
          battletag_full: Blizzard.battletag(),
          battlenet_id: String.t(),
          discord: String.t()
        }
  @callback signup_for_qualifier(signup_options) :: {:ok, any} | {:error, any}
  @type qualifier :: %{
          name: String.t() | nil,
          start_time: NaiveDateTime.t(),
          slug: String.t(),
          region: String.t(),
          id: String.t()
        }
  # @callback get_masters_qualifiers() :: [qualifier]
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
  @callback get_round_standings(Battlefy.stage_id(), integer | String.t()) :: [Standings.t()]
  @callback get_matches(Battlefy.stage_id(), Battlefy.get_matches_options()) :: [Match.t()]
  @callback get_match_deckstrings(Battlefy.tournament_id(), Battlefy.match_id()) :: [
              MatchDeckstrings.t()
            ]
  @callback get_stage(Battlefy.stage_id()) :: Stage.t()
  @callback get_profile(String.t()) :: Profile.t()
  @callback get_user_tournaments(String.t()) :: [Tournament.t()]
end
