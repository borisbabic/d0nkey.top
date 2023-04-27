defmodule Backend.Battlefy.Match do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy.Team
  alias Backend.Battlefy.MatchTeam
  alias Backend.Battlefy.ClassMatchStats
  alias Backend.Battlefy.Match.MatchStats

  typedstruct enforce: true do
    field :id, Backend.Battlefy.match_id()
    field :top, MatchTeam.t()
    field :bottom, MatchTeam.t()
    field :round_number, integer
    field :match_number, integer
    field :double_loss, boolean
    field :stage_id, Backend.Battlefy.stage_id()
    field :is_bye, boolean
    field :completed_at, NaiveDateTime.t()
    field :stats, [MatchStats.t()] | nil
    # field :is_complete, boolean
  end

  @spec find([Match.t()], integer) :: Match.t()
  def find(matches, match_number) do
    matches |> Enum.find(fn %{match_number: mn} -> mn == match_number end)
  end

  @spec filter_team([Match], String.t()) :: [Match]
  def filter_team(matches, team_name) do
    matches
    |> Enum.filter(fn %{top: top, bottom: bottom} ->
      [top, bottom] |> Enum.any?(fn t -> t.team && t.team.name == team_name end)
    end)
  end

  @spec sort_by_round([Match]) :: [Match]
  def sort_by_round(matches) do
    sort_by_round(matches, :asc)
  end

  @spec sort_by_round([Match], :asc | :desc) :: [Match]
  def sort_by_round(matches, direction) do
    matches
    |> Enum.sort_by(fn %{round_number: rn} -> rn end, direction)
  end

  def from_raw_map([match]), do: from_raw_map(match)

  def from_raw_map(
        map = %{
          "roundNumber" => round_number,
          "matchNumber" => match_number,
          "bottom" => bottom,
          "top" => top,
          "isBye" => is_bye,
          "stageID" => stage_id
          # "is_complete" => is_complete
        }
      ) do
    %__MODULE__{
      id: map["id"] || map["_id"],
      top: MatchTeam.from_raw_map(top),
      bottom: MatchTeam.from_raw_map(bottom),
      round_number: round_number,
      match_number: match_number,
      double_loss: map["doubleLoss"] || false,
      is_bye: is_bye,
      completed_at: map["completedAt"] |> Util.naive_date_time_or_nil(),
      stats: MatchStats.from_raw_map(map["stats"]) || [],
      stage_id: stage_id
      # is_complete: is_complete
    }
  end

  def ongoing?(m = %__MODULE__{}) do
    m.completed_at == nil &&
      (m.bottom.winner == false || m.bottom.winner == nil) &&
      (m.top.winner == false || m.top.winner == nil)
  end

  @spec create_class_stats(Match.t(), :bottom | :top) :: [ClassMatchStats.t()]
  def create_class_stats(%{stats: nil}, _), do: nil

  def create_class_stats(m = %__MODULE__{}, place) do
    case Map.get(m, place) do
      nil ->
        nil

      team ->
        collection =
          if team.banned_class, do: %{} |> ClassMatchStats.add_ban(team.banned_class), else: %{}

        m.stats
        |> Enum.reduce(collection, fn s, acc ->
          if s.stats do
            MatchStats.Stats.add_class_stats_for_place(s.stats, acc, place)
          else
            acc
          end
        end)
    end
  end
end

defmodule Backend.Battlefy.MatchTeam do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy.Team
  alias Backend.Battlefy.Util

  typedstruct do
    field :winner, boolean
    field :disqualified, boolean
    field :team, Team.t() | nil
    field :score, integer
    field :banned_class, String.t() | nil
    field :banned_at, NaiveDateTime.t() | nil
    field :ready_at, NaiveDateTime.t() | nil
    field :name, String.t()
  end

  def empty() do
    %__MODULE__{
      winner: false,
      disqualified: false,
      team: nil,
      score: 0,
      name: nil
    }
  end

  def from_raw_map(map) do
    team =
      case map["team"] do
        nil -> nil
        team_map -> Team.from_raw_map(team_map)
      end

    %__MODULE__{
      disqualified: map["disqualified"],
      winner: map["winner"],
      name: map["name"],
      team: team,
      banned_class: map["bannedClass"],
      banned_at: Util.parse_date(map["bannedAt"]),
      ready_at: Util.parse_date(map["readyAt"]),
      score: map["score"] || 0
    }
  end

  def get_name(mt = %__MODULE__{}) do
    cond do
      mt.team && mt.team.name && mt.team.name != "" -> mt.team.name
      mt.name && mt.name != "" -> mt.name
      true -> nil
    end
  end
end

defmodule Backend.Battlefy.ClassMatchStats do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :class, String.t()
    field :wins, integer
    field :losses, integer
    field :bans, integer
  end

  def init(class) do
    %__MODULE__{
      class: class,
      wins: 0,
      losses: 0,
      bans: 0
    }
  end

  def merge(nil, second = %__MODULE__{}), do: second
  def merge(first = %__MODULE__{}, nil), do: first

  def merge(first = %__MODULE__{class: a}, second = %__MODULE__{class: b}) when a == b do
    %__MODULE__{
      class: a,
      wins: first.wins + second.wins,
      losses: first.losses + second.losses,
      bans: first.bans + second.bans
    }
  end

  def init_collection(class_stats = %__MODULE__{}) do
    %{} |> Map.put(class_stats.class, class_stats)
  end

  def merge_collections(first_collection, second_collection) do
    Map.merge(first_collection, second_collection, fn _, first, second -> merge(first, second) end)
  end

  def update_collection(collection, class_stats = %__MODULE__{}) do
    class_stats
    |> init_collection()
    |> merge_collections(collection)
  end

  def add_win(collection, class) do
    collection
    |> update_collection(%__MODULE__{
      class: class,
      wins: 1,
      losses: 0,
      bans: 0
    })
  end

  def add_loss(collection, class) do
    collection
    |> update_collection(%__MODULE__{
      class: class,
      wins: 0,
      losses: 1,
      bans: 0
    })
  end

  def add_ban(collection, class) do
    collection
    |> update_collection(%__MODULE__{
      class: class,
      wins: 0,
      losses: 0,
      bans: 1
    })
  end
end

defmodule Backend.Battlefy.MatchDeckstrings do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :top, [String.t()]
    field :bottom, [String.t()]
  end

  def from_raw_map(%{"top" => top, "bottom" => bottom}) do
    %__MODULE__{
      top: top,
      bottom: bottom
    }
  end

  def from_raw_map(_) do
    %__MODULE__{
      top: [],
      bottom: []
    }
  end

  @spec get(t(), position :: :top | :bottom) :: [String.t()]
  def get(%{top: top}, :top), do: top
  def get(%{bottom: top}, :bottom), do: top

  # todo move to blizzard or hearthstone
  def remove_comments(deckstring) do
    deckstring
    |> String.split("\n")
    |> Enum.filter(fn line -> line && line != "" && String.at(line, 0) != "#" end)
    |> Enum.at(0)
  end
end

defmodule Backend.Battlefy.Match.MatchStats do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy.Match.MatchStats.Stats

  typedstruct enforce: true do
    field :stats, Stats.t()
    field :game_number, integer
    field :created_at, NaiveDateTime.t() | nil
  end

  def from_raw_map(maps) when is_list(maps) do
    maps |> Enum.map(&from_raw_map/1)
  end

  def from_raw_map(map = %{"stats" => stats, "gameNumber" => game_number}) do
    %__MODULE__{
      stats: Stats.from_raw_map(stats),
      created_at: map["createdAt"] |> Util.naive_date_time_or_nil(),
      game_number: game_number
    }
  end

  def from_raw_map(_), do: nil
end

defmodule Backend.Battlefy.Match.MatchStats.Stats do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy.ClassMatchStats
  alias Backend.Battlefy.Match.MatchStats.Stats.StatsTeam

  typedstruct enforce: true do
    field :top, StatsTeam.t()
    field :bottom, StatsTeam.t()
    field :is_complete, boolean
  end

  def from_raw_map(%{"bottom" => bottom, "top" => top, "isComplete" => is_complete}) do
    %__MODULE__{
      top: StatsTeam.from_raw_map(top),
      bottom: StatsTeam.from_raw_map(bottom),
      is_complete: is_complete
    }
  end

  def from_raw_map(_), do: nil

  def add_class_stats_for_place(s = %__MODULE__{}, collection, place) do
    team_stats = Map.get(s, place)

    cond do
      !s.is_complete || !team_stats -> collection
      team_stats.winner -> collection |> ClassMatchStats.add_win(team_stats.class)
      !team_stats.winner -> collection |> ClassMatchStats.add_loss(team_stats.class)
    end
  end
end

defmodule Backend.Battlefy.Match.MatchStats.Stats.StatsTeam do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :class, String.t()
    field :winner, boolean
  end

  def from_raw_map(%{"class" => class, "winner" => winner}) do
    %__MODULE__{
      class: class,
      winner: winner
    }
  end

  def from_raw_map(_), do: nil
end
