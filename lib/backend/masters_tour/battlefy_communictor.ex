defmodule Backend.MastersTour.BattlefyCommunicator do
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
  @callback get_invited_players(tour_stop: String.t() | nil) :: [invited_player]
end
