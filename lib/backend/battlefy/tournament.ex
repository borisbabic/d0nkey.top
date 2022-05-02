defmodule Backend.Battlefy.Tournament do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy
  alias Backend.Battlefy.Util
  alias Backend.Battlefy.Organization
  alias Backend.Battlefy.Tournament.Game
  alias Backend.Battlefy.Tournament.Stream

  typedstruct enforce: true do
    field :id, Battlefy.tournament_id()
    field :stage_ids, [Battlefy.stage_id()]
    field :stages, [Battlefy.Stage.t()]
    field :start_time, Calendar.datetime()
    field :last_completed_match_at, Calendar.datetime() | nil
    field :name, String.t()
    field :slug, String.t()
    field :status, String.t()
    field :region, Backend.Blizzard.region() | nil
    field :organization, Organization | nil
    field :streams, [Stream.t()]
    field :game, Game
  end

  def has_bracket(%{status: "registration-closed"}), do: true

  def has_bracket(%{start_time: start_time}),
    do: NaiveDateTime.utc_now() |> NaiveDateTime.compare(start_time) == :gt

  @spec from_raw_map(map) :: t()
  def from_raw_map(map = %{"startTime" => start_time, "slug" => slug, "name" => name}) do
    region =
      case map["region"] do
        "Americas" -> :US
        "Europe" -> :EU
        "Asia" -> :AP
        _ -> nil
      end

    %__MODULE__{
      id: map["id"] || map["_id"],
      stage_ids: map["stageIDs"] || [],
      slug: slug,
      name: name,
      start_time: NaiveDateTime.from_iso8601!(start_time),
      last_completed_match_at: Util.parse_date(map["lastCompletedMatchAt"]),
      region: region,
      organization: extract_organization(map),
      game: Game.from_raw_map(map["game"]),
      streams: Stream.from_raw_map(map["streams"]),
      status: map["status"],
      stages: extract_stages(map)
    }
  end

  def extract_stages(%{"stages" => stages = [%{"startTime" => _} | _]}) do
    stages |> Enum.map(&Battlefy.Stage.from_raw_map/1)
  end

  def extract_stages(_), do: nil

  def extract_organization(%{"organization" => org = %{"slug" => _}}) do
    Backend.Battlefy.Organization.from_raw_map(org)
  end

  def extract_organization(_), do: nil

  def get_duration(tournament = %__MODULE__{}) do
    case tournament.last_completed_match_at do
      %{calendar: _} ->
        NaiveDateTime.diff(tournament.last_completed_match_at, tournament.start_time)

      _ ->
        nil
    end
  end
end

defmodule Backend.Battlefy.Tournament.Game do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    field :id, Battlefy.tournament_id()
    field :name, String.t()
    field :slug, String.t()
  end

  def from_raw_map(nil), do: nil

  def from_raw_map(map = %{}) do
    %__MODULE__{
      id: map["id"] || map["_id"],
      slug: map["slug"],
      name: map["name"]
    }
  end

  def is_hearthstone(%{game: game}), do: is_hearthstone(game)
  def is_hearthstone(%{slug: "hearthstone"} = %__MODULE__{}), do: true
  def is_hearthstone(%{name: "Hearthstone"} = %__MODULE__{}), do: true
  def is_hearthstone(_), do: false
end

defmodule Backend.Battlefy.Tournament.Stream do

  use TypedStruct

  typedstruct do
    field :link, String.t()
    field :name, String.t()
    field :provider, String.t()
    field :created_at, String.t()
    field :updated_at, String.t()
    field :id, String.t()
  end

  def from_raw_map(nil), do: nil
  def from_raw_map(maps) when is_list(maps), do: Enum.map(maps, &from_raw_map/1) |> Enum.filter(& &1)
  def from_raw_map(raw) do
    %__MODULE__{
      link: raw["link"],
      name: raw["name"],
      provider: raw["provider"],
      id: raw["_id"],
      updated_at: raw["updatedAt"] || raw["updated_at"] |> parse_date(),
      created_at: raw["createdAt"] || raw["created_at"] |> parse_date()
    }
  end

  defp parse_date(nil), do: nil
  defp parse_date(date) do
    case NaiveDateTime.from_iso8601(date) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  def twitch?(%{provider: "twitch.tv"}), do: true
  def twitch?(_), do: false
end
