defmodule Backend.Battlefy.Profile do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :id, String.t()
    field :slug, String.t()
    field :username, String.t()
  end

  def from_raw_map(map = %{"slug" => slug, "username" => username}) do
    %__MODULE__{
      id: map["_id"] || map["id"],
      slug: slug,
      username: username
    }
  end
end
