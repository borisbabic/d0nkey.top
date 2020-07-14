defmodule Backend.Battlefy.Organization do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy

  typedstruct enforce: true do
    field :id, Battlefy.organization_id()
    field :name, String.t()
    field :owner_id, Battlefy.user_id()
    field :slug, String.t()
    field :banner_url, String.t() | nil
    field :logo_url, String.t() | nil
  end

  @spec from_raw_map(map) :: Backend.Battlefy.Organization.t()
  def from_raw_map(map = %{"ownerID" => _}) do
    Recase.Enumerable.convert_keys(
      map,
      &Recase.to_snake/1
    )
    |> from_raw_map
  end

  def from_raw_map(map = %{"owner_id" => owner_id, "name" => name, "slug" => slug}) do
    %__MODULE__{
      id: map["_id"] || map["id"],
      name: name,
      slug: slug,
      owner_id: owner_id,
      banner_url: map["banner_url"],
      logo_url: map["logo_url"]
    }
  end

  def create_link(%{slug: slug}) do
    "https://battlefy.com/#{slug}"
  end
end
