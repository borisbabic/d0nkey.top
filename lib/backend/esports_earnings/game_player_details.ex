defmodule Backend.EsportsEarnings.GamePlayerDetails do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.EsportsEarnings.PlayerDetails

  schema "ee_player_details" do
    field :game_id, :integer
    embeds_many :player_details, PlayerDetails
    timestamps()
  end

  @doc false
  def changeset(details = %__MODULE__{game_id: nil}, attrs) do
    details
    |> cast(attrs, [:game_id])
    |> cast_embed(:player_details)
    |> validate_required([:game_id])
  end

  @doc false
  def changeset(details = %__MODULE__{game_id: gid}, attrs) when is_integer(gid) do
    details
    |> cast(attrs, [])
    |> cast_embed(:player_details)
    |> validate_required([:game_id])
  end
end

defmodule Backend.EsportsEarnings.PlayerDetails do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @all_attrs [:id, :first_name, :last_name, :country_code, :usd_total, :handle]
  @required [:handle, :id]
  @primary_key {:id, :integer, autogenerate: false}
  embedded_schema do
    field :handle, :string
    field :first_name, :string
    field :last_name, :string
    field :country_code, :string
    field :usd_total, :float
  end

  def nillable_name("-"), do: nil
  def nillable_name(name), do: name

  def nillable_country_code(""), do: nil
  def nillable_country_code(cc), do: cc

  def from_raw_map(map = %{"PlayerId" => _}),
    do: map |> Recase.Enumerable.convert_keys(&Recase.to_snake/1) |> from_raw_map()

  def from_raw_map(
        map = %{
          "player_id" => id,
          "country_code" => cc,
          "name_first" => first,
          "name_last" => last,
          "current_handle" => handle
        }
      ) do
    %__MODULE__{
      id: id,
      handle: handle,
      country_code: cc |> String.upcase(),
      first_name: first |> nillable_name(),
      last_name: last |> nillable_name(),
      usd_total: map["total_usd_prize"] || map["total_usdprize"]
    }
  end

  @doc false
  def changeset(_, pd = %__MODULE__{}) do
    pd
    |> to_changeset()
  end

  @doc false
  def changeset(details, attrs) do
    details
    |> cast(attrs, @all_attrs)
    |> validate_required(@required)
  end

  @doc false
  def to_changeset(details) do
    map = details |> Map.from_struct()

    %__MODULE__{}
    |> changeset(map)
  end
end
