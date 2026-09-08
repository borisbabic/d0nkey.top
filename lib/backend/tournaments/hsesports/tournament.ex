defmodule Backend.Tournaments.HSEsports.Tournament do
  @moduledoc """
  Represents an HSEsports tournament with groups and playoff stages parsed from CSV.
  """
  use TypedStruct

  typedstruct do
    field :id, String.t(), default: "wc_2026"
    field :name, String.t(), default: "Hearthstone World Championship 2026"
    field :start_time, NaiveDateTime.t()
    field :tags, [atom()], default: [:bo5]
    field :groups, [{String.t(), [map()]}], default: []
    field :playoffs, [map()], default: []
    field :matches, [map()], default: []
    field :match_stats, [Backend.Tournaments.MatchStats.t()], default: []
    field :raw_csv, String.t(), default: ""
    field :last_updated_at, DateTime.t()
  end
end

defimpl Backend.Tournaments.Tournament, for: Backend.Tournaments.HSEsports.Tournament do
  def id(%{id: id}), do: id
  def name(%{name: name}), do: name
  def link(_), do: "/wc/2026"
  def start_time(%{start_time: start_time}), do: start_time
  def standings_link(_), do: "/wc/2026"
  def tags(%{tags: tags}), do: tags
end
