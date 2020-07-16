defmodule Backend.Battlefy.Organization do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy

  typedstruct enforce: true do
    field :id, Battlefy.organization_id()
    field :name, String.t() | nil
    field :owner_id, Battlefy.user_id() | nil
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

  def from_raw_map(map = %{"slug" => slug}) do
    %__MODULE__{
      id: map["_id"] || map["id"],
      name: map["name"],
      slug: slug,
      owner_id: map["owner_id"],
      banner_url: map["banner_url"],
      logo_url: map["logo_url"]
    }
  end

  def display_name(%{name: nil, slug: slug}), do: slug
  def display_name(%{name: name}), do: name

  def create_link(%{slug: slug}) do
    "https://battlefy.com/#{slug}"
  end
end
