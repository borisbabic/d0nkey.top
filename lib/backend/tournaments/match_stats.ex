defmodule Backend.Tournaments.MatchStats do
  @moduledoc false
  use TypedStruct
  alias Backend.Tournaments.MatchStats.Result

  typedstruct do
    field :banned, [String.t()], default: []
    field :not_banned, [String.t()], default: []
    field :results, [Result.t()], default: []
  end

  def winner_loser_pairs(%{results: results}) do
    Enum.flat_map(results, fn %{winner_loser_pairs: pairs} -> pairs end)
  end
end

defmodule Backend.Tournaments.MatchStats.Result do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :winner_loser_pairs, [{String.t(), String.t()}]
  end
end
