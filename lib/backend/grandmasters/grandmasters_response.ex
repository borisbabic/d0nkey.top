defmodule Backend.Grandmasters.Response do
  @moduledoc false
  use TypedStruct

  alias Backend.Grandmasters.Response.Season
  alias Backend.Grandmasters.Response.Time
  alias Backend.Grandmasters.Response.Tournament
  alias Backend.Grandmasters.Response.Match
  alias Backend.Hearthstone.Deck

  typedstruct enforce: true do
    field :requested_season_tournaments, [Tournament.t()]

    field :seasons, [Season.t()]

    field :requested_season, Season.t()
    field :default_season, Season.t()

    field :season_start, Time.t()
    field :season_end, Time.t()
  end

  def from_raw_map(map = %{"seasonStart" => _}),
    do: map |> Recase.Enumerable.convert_keys(&Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(map) do
    requested_raw = map["requested_season_tournaments"]

    %{
      requested_season_tournaments: requested_raw |> Enum.map(&Tournament.from_raw_map/1),
      seasons: map["seasons"] |> Enum.map(&Season.from_raw_map/1),
      requested_season: Season.from_raw_map(map["requested_season"]),
      default_season: Season.from_raw_map(map["default_season"]),
      season_start: Time.from_raw_map(map["season_start"]),
      season_end: Time.from_raw_map(map["season_end"])
    }
  end

  def stage_titles(%{requested_season_tournaments: tournaments}) do
    tournaments
    |> Enum.flat_map(& &1.stages)
    |> Enum.map(& &1.title)
    |> Enum.uniq()
  end

  def results(r, stage_title) when is_binary(stage_title),
    do: results(r, &(&1.title == stage_title))

  def results(r, stage_matcher) when is_function(stage_matcher) do
    r
    |> matches(stage_matcher)
    |> Enum.flat_map(&if(&1.winner, do: [&1.winner], else: []))
    |> Enum.group_by(& &1.name)
    |> Enum.map(fn {gm, l} -> {gm, l |> Enum.count()} end)
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Map.new()
  end

  def matches(%{requested_season_tournaments: tournaments}, stage_matcher) do
    tournaments
    |> Enum.flat_map(& &1.stages)
    |> Enum.filter(stage_matcher)
    |> Enum.flat_map(& &1.brackets)
    |> Enum.flat_map(& &1.matches)
  end

  def regionified_competitors(%{requested_season_tournaments: tournaments}) do
    tournaments
    |> Enum.map(fn t ->
      competitors =
        t.stages
        |> Enum.flat_map(& &1.brackets)
        |> Enum.flat_map(& &1.matches)
        |> Enum.flat_map(& &1.competitors)
        |> Enum.filter(& &1)
        |> Enum.uniq_by(& &1.id)

      {String.to_atom(t.region), competitors}
    end)
  end

  def decklists(r) do
    decklists(r, fn %{brackets: [b | _]} ->
      b.matches
      |> case do
        [%{start_date: start_date} | _] when is_integer(start_date) ->
          match_week =
            start_date
            |> div(1000)
            |> DateTime.from_unix!()
            |> DateTime.to_date()
            |> Date.to_erl()
            |> :calendar.iso_week_number()

          current_week = Date.utc_today() |> Date.to_erl() |> :calendar.iso_week_number()
          match_week == current_week

        _ ->
          false
      end
    end)
  end

  def decklists(r, matcher)
      when is_function(matcher) do
    r
    |> matches(matcher)
    |> Enum.flat_map(&Match.decklists/1)
    |> Enum.filter(fn {competitor, lists} -> competitor != nil && lists |> Enum.any?() end)
    |> Enum.reduce(%{}, fn {competitor, lists}, carry ->
      existing_lists =
        carry
        |> Map.get(competitor.name)
        |> case do
          {_, codes} when is_list(codes) -> codes
          _ -> []
        end

      filtered =
        lists
        |> Enum.reduce([], fn code, carry ->
          case Deck.canonical_constructed_deckcode(code) do
            {:ok, deckcode} -> [deckcode | carry]
            _ -> carry
          end
        end)
        |> Kernel.++(existing_lists)
        |> Enum.uniq()

      carry |> Map.put(competitor.name, {competitor, filtered})
    end)
    |> Map.values()
  end

  def decklists(r, stage_title) when is_binary(stage_title) do
    decklists(r, &(&1.title == stage_title))
  end
end

defmodule Backend.Grandmasters.Response.Tournament do
  @moduledoc false
  use TypedStruct

  alias Backend.Grandmasters.Response.Stage

  typedstruct enforce: true do
    field :id, integer
    field :available_languages, [String.t()]
    field :game, String.t()
    field :region, String.t()
    field :featured, boolean
    field :draft, boolean
    field :title, String.t()
    field :stages, [Stage.t()]
    field :etag, String.t()
  end

  def from_raw_map(map = %{"availableLanguages" => _}),
    do: map |> Recase.Enumerable.convert_keys(&Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(map) do
    %{
      id: map["id"],
      available_languages: map["available_languages"],
      game: map["game"],
      region: map["region"],
      featured: map["featured"],
      draft: map["draft"],
      title: map["title"],
      etag: map["@etag"],
      stages: map["stages"] |> Enum.map(&Stage.from_raw_map/1)
    }
  end
end

defmodule Backend.Grandmasters.Response.Stage do
  @moduledoc false
  use TypedStruct

  alias Backend.Grandmasters.Response.Bracket

  typedstruct enforce: true do
    field :id, integer
    field :available_languages, String.t()
    field :title, String.t()
    field :detail, String.t()
    field :tournament_id, integer
    field :etag, String.t()
  end

  def from_raw_map(map = %{"availableLanguages" => _}),
    do: map |> Recase.Enumerable.convert_keys(&Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(map) do
    %{
      id: map["id"],
      available_languages: map["available_languages"],
      draft: map["draft"],
      title: map["title"],
      tournament_id: map["tournament_id"],
      etag: map["@etag"],
      brackets: map["brackets"] |> Enum.map(&Bracket.from_raw_map/1)
    }
  end
end

defmodule Backend.Grandmasters.Response.Bracket do
  @moduledoc false
  use TypedStruct
  alias Backend.Grandmasters.Response.Match
  alias Backend.Grandmasters.Response.Competitor

  typedstruct enforce: true do
    field :id, integer
    field :available_languages, String.t()
    field :name, String.t()
    # field :best_of, integer, required: false
    # field :match_conclusion_value, integer
    # field :match_conclusion_strategy, String.t()
    # field :winners, integer
    # field :competitor_size, integer
    # field :team_size, integer
    # field :advantage_comparing
    # field :repeatable_matchups, integer
    # field :type, String.t() # example "DE" for double elimination
    # .... more, fuck this shit
    field :stage_id, integer
    # field :rankings, Rankings.t()
    field :matches, [Match.t()]
    field :competitors, [Competitor.t()]
  end

  def from_raw_map(map = %{"availableLanguages" => _}),
    do: map |> Recase.Enumerable.convert_keys(&Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(map) do
    %{
      id: map["id"],
      available_languages: map["available_languages"],
      name: map["name"],
      stage_id: map["stage_id"],
      competitors: map["competitors"] |> Enum.map(&Competitor.from_raw_map/1),
      matches: map["matches"] |> Enum.map(&Match.from_raw_map/1)
    }
  end
end

defmodule Backend.Grandmasters.Response.Match do
  @moduledoc false
  use TypedStruct
  alias Backend.Grandmasters.Response.Competitor

  typedstruct enforce: true do
    field :id, integer
    field :available_languages, String.t()
    field :round, integer
    field :winner, Competitor.t() | nil
    field :competitors, [Competitor.t()]
    field :status, String.t()
    field :state, String.t()
    field :start_date, integer | nil
    field :decklists, [[String.t()]]
  end

  def concluded?(%{status: "CONCLUDED"}), do: true
  def concluded?(_), do: false
  def finished?(this), do: concluded?(this)

  @spec decklists(__MODULE__) :: [{Competitor.t(), [String.t()]}]
  def decklists(%{competitors: c, decklists: d}), do: Enum.zip(c, d)

  def from_raw_map(map = %{"availableLanguages" => _}),
    do: map |> Recase.Enumerable.convert_keys(&Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(nil), do: nil

  def from_raw_map(map) do
    start_date =
      if is_integer(map["start_date"]) do
        div(map["start_date"], 1000)
      else
        nil
      end

    %{
      id: map["id"],
      available_languages: map["available_languages"],
      round: map["round"],
      winner: map["winner"] |> Competitor.from_raw_map(),
      competitors: map["competitors"] |> Enum.map(&Competitor.from_raw_map/1),
      status: map["status"],
      state: map["state"],
      decklists: parse_decklists(map)
    }
  end

  def parse_decklists(map = %{"attributes" => %{"competitor_1" => _}}) do
    ["competitor_1", "competitor_2"]
    |> Enum.map(fn n ->
      get_in(map, ["attributes", n, "decklist"])
      |> case do
        nil -> []
        codes -> codes |> Enum.map(& &1["deck_code"])
      end
    end)
  end

  def parse_decklists(map = %{"attributes" => %{"competitor_1_decklists" => _}}) do
    ["competitor_1_decklists", "competitor_2_decklists"]
    |> Enum.map(fn n ->
      get_in(map, ["attributes", n])
      |> case do
        nil -> []
        codes -> codes
      end
    end)
  end

  def parse_decklists(_), do: [[], []]
end

defmodule Backend.Grandmasters.Response.Competitor do
  @moduledoc false
  use TypedStruct
  alias Backend.Grandmasters.Response.Time

  typedstruct enforce: true do
    field :id, integer
    field :available_languages, String.t()
    field :name, String.t()
    field :nationality, String.t()
    field :headshot, String.t()
  end

  def from_raw_map(map = %{"availableLanguages" => _}),
    do: map |> Recase.Enumerable.convert_keys(&Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(nil), do: nil

  def from_raw_map(map) do
    %{
      id: map["id"],
      available_languages: map["available_languages"],
      name: map["name"],
      nationality: map["nationality"],
      headshot: map["headshot"]
    }
  end
end

defmodule Backend.Grandmasters.Response.Season do
  @moduledoc false
  use TypedStruct
  alias Backend.Grandmasters.Response.Time

  typedstruct enforce: true do
    field :season, integer
    field :year, integer
    field :start_date, Time.t()
    field :end_date, Time.t()
  end

  def from_raw_map(map = %{"startDate" => _}),
    do: map |> Recase.Enumerable.convert_keys(&Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(map) do
    %__MODULE__{
      season: map["season"],
      year: map["year"],
      start_date: Time.from_raw_map(map["start_date"]),
      end_date: Time.from_raw_map(map["end_date"])
    }
  end
end

defmodule Backend.Grandmasters.Response.Time do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :time, integer
    field :time_zone, String.t()
  end

  def from_raw_map(map = %{"timeZone" => _}),
    do: map |> Recase.Enumerable.convert_keys(&Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(%{"time" => time, "time_zone" => time_zone}) do
    %__MODULE__{
      time: div(time, 1000),
      time_zone: time_zone
    }
  end
end
