defmodule Backend.Battlenet.Battletag do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "battletag_info" do
    field :battletag_full, :string
    field :battletag_short, :string
    field :country, :string
    field :priority, :integer
    field :reported_by, :string
    field :comment, :string

    timestamps()
  end

  @battletag_regex ~r/(^([A-zÀ-ú][A-zÀ-ú0-9]{2,11})|(^([а-яёА-ЯЁÀ-ú][а-яёА-ЯЁ0-9À-ú]{2,11})))(#[0-9]{4,})$/
  @short_regex ~r/(^([A-zÀ-ú][A-zÀ-ú0-9]{2,11})|(^([а-яёА-ЯЁÀ-ú][а-яёА-ЯЁ0-9À-ú]{2,11})))$/

  @doc false
  def changeset(battletag, attrs) do
    battletag
    |> cast(attrs, [
      :battletag_full,
      :battletag_short,
      :country,
      :priority,
      :reported_by,
      :comment
    ])
    |> validate_required([:country, :priority, :reported_by])
    |> add_short()
  end

  # If the changeset includes just the full battletag the short one will also be added
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

  def long?(string) do
    String.match?(string, @battletag_regex)
  end

  def short?(string) do
    String.match?(string, @short_regex)
  end
end
