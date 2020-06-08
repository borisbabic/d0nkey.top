defmodule Backend.EsportsGold.PlayerDetails do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :alias, string
    field :nationality, string
    field :twitter, string
    field :twitch, string
  end

  def from_raw_map(nil) do
    nil
  end

  def from_raw_map(%{
        "alias" => alias,
        "nationality" => nationality,
        "twitch" => twitch,
        "twitter" => twitter
      }) do
    %__MODULE__{
      alias: alias,
      nationality: nationality,
      twitch: twitch,
      twitter: twitter
    }
  end

  def from_raw_map(%{"data" => %{"player" => %{"details" => details}}}) do
    from_raw_map(details)
  end

  def from_alias(alias) do
    %__MODULE__{
      alias: alias,
      nationality: "",
      twitch: "",
      twitter: ""
    }
  end
end
