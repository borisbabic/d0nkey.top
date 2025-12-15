defmodule Backend.Battlefy.Team do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy.Team.Player
  import Backend.Battlefy.Util, only: [parse_date: 1]

  typedstruct do
    field :name, String.t()
    field :checked_in_at, NaiveDateTime.t() | nil
    field :created_at, NaiveDateTime.t() | nil
    field :updated_at, NaiveDateTime.t() | nil
    field :user_id, String.t()
    field :owner_id, String.t()
    field :captain_id, String.t()
    field :country_flag, String.t()
    field :custom_fields, [any()]
    field :players, [Player.t()]
  end

  @spec country_code(t()) :: String.t() | nil
  def country_code(team) do
    from_team = team |> Map.get(:country_flag) |> Util.get_country_code()

    from_players =
      Map.get(team, :players, [])
      |> Enum.map(&Map.get(&1, :country_code))
      |> Enum.uniq()
      |> case do
        [code] when is_binary(code) -> code
        _ -> nil
      end

    from_team || from_players
  end

  [:twitch, :slug, :battletag]
  |> Enum.each(fn attr ->
    def unquote(attr)(%{player: [p]}), do: p[unquote(attr)]
    def unquote(attr)(_), do: nil
  end)

  @spec player_or_team_name(team :: __MODULE__.t()) :: name :: String.t() | nil
  def player_or_team_name(%{players: [%{name: name}]}) when is_binary(name), do: name
  def player_or_team_name(%{name: name}) when is_binary(name), do: name
  def player_or_team_name(_), do: nil

  def from_raw_map(map = %{"name" => name}) do
    %__MODULE__{
      name: name,
      user_id: map["userID"],
      owner_id: map["ownerID"],
      captain_id: map["captainID"],
      created_at: parse_date(map["createdAt"]),
      updated_at: parse_date(map["updatedAt"]),
      checked_in_at: parse_date(map["checkedInAt"]),
      country_flag: map["countryFlag"],
      custom_fields: map["customFields"],
      players:
        if(map["players"] |> is_list(),
          do: map["players"] |> Enum.map(&Player.from_raw_map/1),
          else: []
        )
    }
  end

  def from_raw_map(_), do: %__MODULE__{}
end

defmodule Backend.Battlefy.Team.Player do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :battletag, String.t() | nil
    field :country_code, String.t() | nil
    field :twitch, String.t() | nil
    field :in_game_name, String.t() | nil
    field :user_id, String.t() | nil
    field :slug, String.t() | nil
  end

  def from_raw_map(map = %{"userID" => _}) do
    %__MODULE__{
      in_game_name: map["inGameName"],
      user_id: map["userID"],
      battletag: get_in(map, ["user", "accounts", "battlenet", "battletag"]),
      twitch: get_in(map, ["user", "accounts", "twitch"]),
      country_code: get_in(map, ["user", "countryCode"]),
      slug: map["slug"]
    }
  end

  def from_raw_map(_), do: %{}
end
