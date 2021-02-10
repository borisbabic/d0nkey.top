defmodule Backend.Battlenet.Battletag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "battletag_info" do
    field :battletag_full, :string
    field :battletag_short, :string
    field :country, :string
    field :priority, :integer
    field :reported_by, :string

    timestamps()
  end

  @doc false
  def changeset(battletag, attrs) do
    battletag
    |> cast(attrs, [:battletag_full, :battletag_short, :country, :priority, :reported_by])
    |> validate_required([:country, :priority, :reported_by])
    |> add_short()
  end

  @doc """
  If the changeset includes just the full battletag the short one will also be added
  """
  @spec add_short(Ecto.Changset.t()) :: Ecto.Changeset.t()
  defp add_short(cs) do
    with :error <- cs |> fetch_change(:battletag_short),
         {:ok, full} <- cs |> fetch_change(:battletag_full) do
      cs |> put_change(:battletag_short, full |> shorten())
    else
      _ -> cs
    end
  end

  @spec shorten(%{battletag_full: String.t()} | String.t()) :: String.t()
  def shorten(%{battletag_full: full}) when is_binary(full), do: full |> shorten()

  def shorten(full) when is_binary(full),
    do: full |> Backend.MastersTour.InvitedPlayer.shorten_battletag()
end
