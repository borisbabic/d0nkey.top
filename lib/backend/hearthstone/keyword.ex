defmodule Backend.Hearthstone.Keyword do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  schema "hs_keywords" do
    field :game_modes, {:array, :integer}
    field :name, :string
    field :ref_text, :string
    field :slug, :string
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(keyword, %Hearthstone.Metadata.Keyword{} = struct) do
    attrs = Map.from_struct(struct)

    keyword
    |> cast(attrs, [:id, :name, :slug, :game_modes, :ref_text, :text])
    |> validate_required([:id, :name, :slug, :game_modes, :ref_text, :text])
  end

  @spec secret?(%__MODULE__{}) :: boolean
  def secret?(keyword), do: matches?(keyword, "secret")

  @spec questline?(%__MODULE__{}) :: boolean
  def questline?(keyword), do: matches?(keyword, "questline")

  @spec quest?(%__MODULE__{}) :: boolean
  def quest?(keyword), do: matches?(keyword, "quest")

  @spec matches?(%__MODULE__{}, String.t()) :: boolean
  def matches?(%{slug: matching}, matching), do: true
  def matches?(%{name: matching}, matching), do: true
  # bug with the official api
  def matches?(%{slug: slug}, search), do: slug == search <> "\n"
end
