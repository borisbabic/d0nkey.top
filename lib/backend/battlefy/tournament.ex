defmodule Backend.Battlefy.Tournament do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy
  alias Backend.Battlefy.Util
  alias Backend.Battlefy.Organization
  alias Backend.Battlefy.Tournament.Game
  alias Backend.Battlefy.Tournament.Stream
  alias Backend.Battlefy.Tournament.CustomField
  alias Backend.Battlefy.Tournament.GameAttributes

  typedstruct enforce: true do
    field :id, Battlefy.tournament_id()
    field :stage_ids, [Battlefy.stage_id()]
    field :stages, [Battlefy.Stage.t()]
    field :start_time, Calendar.datetime()
    field :custom_fields, [CustomField.t()]
    field :last_completed_match_at, Calendar.datetime() | nil
    field :name, String.t()
    field :slug, String.t()
    field :status, String.t()
    field :region, Backend.Blizzard.region() | nil
    field :organization, Organization | nil
    field :streams, [Stream.t()]
    field :game_attributes, GameAttributes.t() | nil
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
      custom_fields: CustomField.from_raw_map(map["customFields"]),
      organization: extract_organization(map),
      game: Game.from_raw_map(map["game"]),
      streams: Stream.from_raw_map(map["streams"]),
      status: map["status"],
      game_attributes:
        GameAttributes.from_raw_map(map["gameAttributes"] || map["game_attributes"]),
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

  def tags(%__MODULE__{} = tournament) do
    []
    |> add_region(tournament)
    |> add_organizer_specific_tags(tournament)
    |> GameAttributes.tags(tournament)
  end

  defp add_organizer_specific_tags(previous, %{organization: %{id: "67ba48aa980e5d02ecae2be0"}}) do
    [:toxic_community | previous]
  end

  defp add_organizer_specific_tags(previous, _), do: previous

  defp add_region(previous, %{region: region}) when is_atom(region) do
    [region | previous]
  end

  defp add_region(previous, _), do: previous
end

defmodule Backend.Battlefy.Tournament.CustomField do
  use TypedStruct

  typedstruct enforce: false do
    field :id, Battlefy.tournament_id()
    field :name, String.t()
    field :public, boolean()
  end

  def from_raw_map(nil), do: nil

  def from_raw_map(maps) when is_list(maps),
    do: Enum.map(maps, &from_raw_map/1) |> Enum.filter(& &1)

  def from_raw_map(raw) do
    %__MODULE__{
      id: raw["_id"],
      name: raw["name"],
      public: raw["public"] || false
    }
  end

  def value(target, field_id, default \\ nil)
  def value(%{id: id, value: value}, field_id, _default) when id == field_id, do: value

  def value(%{custom_fields: cf}, field_id, default), do: value(cf, field_id, default)

  def value(fields, field_id, default) when is_list(fields) do
    Enum.find_value(fields, default, fn
      %{id: ^field_id, value: value} -> value
      # raw
      %{"_id" => ^field_id, "value" => value} -> value
      _ -> false
    end)
  end

  def value(_, _, default), do: default
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

  def from_raw_map(maps) when is_list(maps),
    do: Enum.map(maps, &from_raw_map/1) |> Enum.filter(& &1)

  def from_raw_map(raw) do
    %__MODULE__{
      link: raw["link"],
      name: raw["name"],
      provider: raw["provider"],
      id: raw["_id"],
      updated_at: (raw["updatedAt"] || raw["updated_at"]) |> parse_date(),
      created_at: (raw["createdAt"] || raw["created_at"]) |> parse_date()
    }
  end

  def parse_date(nil), do: nil

  def parse_date(date) do
    case NaiveDateTime.from_iso8601(date) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  def twitch?(%{provider: "twitch.tv"}), do: true
  def twitch?(_), do: false
end

defmodule Backend.Battlefy.Tournament.GameAttributes do
  use TypedStruct
  import Backend.Battlefy.Tournament.Stream, only: [parse_date: 1]
  alias Hearthstone.Enums.Format

  typedstruct do
    field :ban_enabled, boolean(), required: false
    field :classes_per_player, integer(), required: false
    field :deck_publish_and_lock_time, NaiveDateTime.t(), required: false
    field :hearthstone_card_format, integer(), required: false
    field :hearthstone_deck_format, String.t(), required: false
    field :open_deck_format?, boolean(), required: false
    field :standard_year, String.t(), required: false
  end

  def from_raw_map(raw) when is_map(raw) do
    %__MODULE__{
      ban_enabled: parse_ban_enabled(raw),
      classes_per_player: raw["classesPerPlayer"] || raw["classes_per_player"],
      deck_publish_and_lock_time:
        (raw["deckPublishAndLockTime"] || raw["deck_publish_and_lock_time"]) |> parse_date(),
      hearthstone_card_format:
        parse_card_format(raw["hearthstone_card_format"] || raw["hearthstoneCardFormat"]),
      hearthstone_deck_format: raw["hearthstoneDeckFormat"] || raw["hearthstone_deck_format"],
      open_deck_format?:
        raw["isOpenDeckFormat"] || raw["is_open_deck_format"] || raw["open_deck_format?"],
      standard_year: raw["standardYear"] || raw["standard_year"]
    }
  end

  def from_raw_map(_), do: nil

  def parse_ban_enabled(%{"banEnabled" => ban_enabled}), do: ban_enabled
  def parse_ban_enabled(%{"ban_enabled" => ban_enabled}), do: ban_enabled
  def parse_ban_enabled(_), do: nil
  def parse_card_format(nil), do: nil
  def parse_card_format(format), do: Format.parse(format)

  @spec tags([atom()], t() | Backend.Battlefy.Tournament.t()) :: atom()
  def tags(previous_tags \\ [], game_attributes)

  def tags(previous_tags, %{game_attributes: game_attribues}),
    do: tags(previous_tags, game_attribues)

  def tags(previous_tags, game_attributes) do
    previous_tags
    |> add_best_of(game_attributes)
    |> add_format(game_attributes)
    |> add_open(game_attributes)
  end

  defp add_best_of(previous, %{classes_per_player: classes} = game_attributes)
       when is_integer(classes) do
    subtraction = if game_attributes.ban_enabled, do: 1, else: 0
    actual = classes - subtraction

    case actual do
      1 -> [:bo1 | previous]
      2 -> [:bo3 | previous]
      3 -> [:bo5 | previous]
      4 -> [:bo7 | previous]
      _ -> previous
    end
  end

  defp add_best_of(previous, _), do: previous

  defp add_format(previous, %{format: format}) when is_integer(format) do
    all = Format.all(:atoms)

    case Enum.find_value(all, fn {id, atom} -> id == format and atom end) do
      atom when is_atom(atom) -> [atom | previous]
      _ -> previous
    end
  end

  defp add_format(previous, _), do: previous

  defp add_open(previous, %{open_deck_format?: open?}) do
    case open? do
      true -> [:open | previous]
      false -> [:closed | previous]
      _ -> previous
    end
  end

  defp add_open(previous, _), do: previous
end
