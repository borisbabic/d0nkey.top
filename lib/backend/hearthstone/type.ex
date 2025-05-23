defmodule Backend.Hearthstone.Type do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}
  schema "hs_type" do
    field :game_modes, {:array, :integer}
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(type, %Hearthstone.Metadata.Type{} = struct) do
    attrs = Map.from_struct(struct)

    type
    |> cast(attrs, [:id, :name, :slug, :game_modes])
    |> validate_required([:id, :name, :slug, :game_modes])
  end

  @spec upcase(%__MODULE__{} | String.t()) :: String.t()
  def upcase(%{slug: slug}), do: upcase(slug)
  def upcase(slug) when is_binary(slug), do: String.upcase(slug)
  def upcase(nil), do: nil
end
