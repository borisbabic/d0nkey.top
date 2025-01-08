defmodule Backend.Hearthstone.Set do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}
  schema "hs_sets" do
    field :collectible_count, :integer
    field :collectible_revealed_count, :integer
    field :name, :string
    field :non_collectible_count, :integer
    field :non_collectible_revelead_count, :integer
    field :slug, :string
    field :type, :string
    field :release_date, :date

    timestamps()
  end

  @doc false
  def changeset(set, %Hearthstone.Metadata.Set{} = struct) do
    attrs = Map.from_struct(struct)

    set
    |> cast(attrs, [
      :id,
      :name,
      :slug,
      :collectible_count,
      :collectible_revealed_count,
      :non_collectible_count,
      :non_collectible_revelead_count,
      :type
    ])
    |> validate_required([
      :id,
      :name,
      :slug,
      :collectible_count,
      :collectible_revealed_count,
      :non_collectible_count
    ])
  end

  def set_release_date(set, release_date) do
    set
    |> cast(%{release_date: release_date}, [:release_date])
    |> validate_required([:release_date])
  end

  # TODO add this to the DB
  def abbreviation(%{slug: "united-in-stormwind"}), do: "UiS"
  def abbreviation(%{slug: "journey-to-ungoro"}), do: "JtU"
  def abbreviation(%{slug: "galakronds-awakening"}), do: "GA"
  def abbreviation(%{slug: "saviors-of-uldum"}), do: "SoU"
  def abbreviation(_), do: nil
end
