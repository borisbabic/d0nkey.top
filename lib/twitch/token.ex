defmodule Twitch.Token do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :access_token, String.t()
    field :expires_in, number
    field :expires_at, NaiveDateTime.t()
    field :refresh_token, String.t() | nil
    field :scope, [String.t()]
    field :token_type, String.t()
  end

  def from_raw_map(
        map = %{
          "access_token" => access_token,
          "expires_in" => expires_in_raw,
          "token_type" => token_type
        }
      ) do
    now = NaiveDateTime.utc_now()
    expires_in = expires_in_raw |> Util.to_int_or_orig()
    expires_at = NaiveDateTime.add(now, expires_in)

    %__MODULE__{
      access_token: access_token,
      expires_at: expires_at,
      expires_in: expires_in,
      refresh_token: map["refresh_token"],
      scope: map["scope"] || [],
      token_type: token_type
    }
  end
end
