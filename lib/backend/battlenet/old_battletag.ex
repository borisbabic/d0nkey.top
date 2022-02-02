defmodule Backend.Battlenet.OldBattletag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.Battlenet.Battletag

  schema "old_battletags" do
    belongs_to :user, User
    field :new_battletag, :string
    field :old_battletag, :string
    field :old_battletag_short, :string
    field :new_battletag_short, :string
    field :source, :string

    timestamps()
  end

  @doc false
  def changeset(old_battletag, attrs) do
    old_battletag
    |> cast(attrs, [:new_battletag, :old_battletag, :source, :user_id, :new_battletag_short, :old_battletag_short])
    |> validate_required([:new_battletag, :old_battletag, :source])
    |> add_short(:old_battletag, :old_battletag_short)
    |> add_short(:new_battletag, :new_battletag_short)
  end

  @spec add_short(Ecto.Changset.t(), atom(), atom()) :: Ecto.Changeset.t()
  defp add_short(cs, full_attr, old_attr) do
    with :error <- cs |> fetch_change(old_attr),
         {:ok, full} <- cs |> fetch_change(full_attr) do
      cs |> put_change(old_attr, Battletag.shorten(full))
    else
      _ -> cs
    end
  end
end
