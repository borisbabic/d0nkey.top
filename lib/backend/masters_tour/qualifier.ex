defmodule Backend.MastersTour.Qualifier do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.MastersTour.Qualifier.Standings
  @type type :: :single_elimination

  @non_embed_attrs [
    :tour_stop,
    :start_time,
    :end_time,
    :region,
    :tournament_id,
    :tournament_slug,
    :winner,
    :type
  ]
  @embed_attrs [:standings]
  @all_attrs @non_embed_attrs ++ @embed_attrs
  schema "qualifier" do
    field :tour_stop, :string
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :region, :string
    field :tournament_id, :string
    field :tournament_slug, :string
    field :winner, :string
    field :type, :string
    embeds_many(:standings, Standings)
    timestamps()
  end

  @doc false
  def changeset(qualifier = %__MODULE__{tour_stop: nil}, attrs) do
    qualifier
    |> cast(attrs, @non_embed_attrs)
    |> cast_embed(:standings)
    |> validate_required(@all_attrs)
  end
end

defmodule Backend.MastersTour.Qualifier.Standings do
  use Ecto.Schema
  import Ecto.Changeset
  @all_attrs [:battletag_full, :wins, :losses, :position]
  @primary_key {:battletag_full, :string, autogenerate: false}
  embedded_schema do
    field :wins, :integer
    field :losses, :integer
    field :position, :integer
  end

  @doc false
  def changeset(standings, attrs) do
    standings
    |> cast(attrs, @all_attrs)
    |> validate_required(@all_attrs)
  end
end
