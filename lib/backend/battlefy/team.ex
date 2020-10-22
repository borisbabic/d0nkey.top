defmodule Backend.Battlefy.Team do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy.Team.Player

  typedstruct do
    field :name, String.t()
    field :players, [Player.t()]
  end

  [:twitch, :slug, :country_code, :battletag]
  |> Enum.each(fn attr ->
    def unquote(attr)(%{player: [p]}), do: p[unquote(attr)]
    def unquote(attr)(_), do: nil
  end)

  def from_raw_map(map = %{"name" => name}) do
    %__MODULE__{
      name: name,
      players:
        if(map["players"] |> is_list(),
          do: map["players"] |> Enum.map(&Player.from_raw_map/1),
          else: []
        )
    }
  end
end

defmodule Backend.Battlefy.Team.Player do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :battletag, String.t() | nil
    field :country_code, String.t() | nil
    field :twitch, String.t() | nil
    field :slug, String.t() | nil
  end

  def from_raw_map(map = %{"userID" => _}),
    do: Recase.Enumerable.convert_keys(map, &Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(map = %{"user_id" => _}) do
    # IO.inspect(map)
    %__MODULE__{
      battletag: get_in(map, ["user", "accounts", "battlenet", "battletag"]),
      twitch: get_in(map, ["user", "accounts", "twitch"]),
      country_code: get_in(map, ["user", "country_code"]),
      slug: map["slug"]
    }
  end
end
