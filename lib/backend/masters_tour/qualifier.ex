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


  def num(slug) when is_binary(slug) do
    slug
    |> String.split("-")
    |> Enum.at(-1)
    |> Util.to_int(nil)
  end
  def num(%{slug: slug}), do: num(slug)
  def num(%{tournament_slug: tournament_slug}), do: num(tournament_slug)
  def num(_), do: nil

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

  @spec no_result?(Standings.t()) :: boolean
  def no_result?(standings), do: standings.wins + standings.losses < 1

  @spec no_result(Standings.t()) :: integer
  def no_result(standings), do: if(no_result?(standings), do: 1, else: 0)

  @spec only_losses?(Standings.t()) :: boolean
  def only_losses?(standings), do: standings.wins < 1 && standings.losses > 0

  @spec only_losses(Standings.t()) :: integer
  def only_losses(standings), do: if(only_losses?(standings), do: 1, else: 0)

  @spec won?(Standings.t()) :: boolean
  def won?(standings), do: standings.position == 1
  @spec won(Standings.t()) :: integer
  def won(standings), do: if(won?(standings), do: 1, else: 0)

  @spec top8?(Standings.t()) :: boolean
  def top8?(standings), do: standings.position < 9

  @spec top8(Standings.t()) :: integer
  def top8(standings), do: if(top8?(standings), do: 1, else: 0)

  @spec top16?(Standings.t()) :: boolean
  def top16?(standings), do: standings.position < 17

  @spec top16(Standings.t()) :: integer
  def top16(standings), do: if(top16?(standings), do: 1, else: 0)
end
