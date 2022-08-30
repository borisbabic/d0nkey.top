defmodule Hearthstone.Leaderboards.Season do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: false do
    field :leaderboard_id, String.t() | nil
    field :region, String.t() | nil
    field :season_id, integer() | nil
  end

  def default_leaderboard_id(), do: "STD"
  def default_region(), do: "EU"

  def ensure_region(season, default \\ nil) do
    %{season | region: season.region || default || default_region()}
  end

  def ensure_leaderboard_id(season, default \\ nil) do
    %{season | leaderboard_id: season.leaderboard_id || default || default_leaderboard_id()}
  end
end
