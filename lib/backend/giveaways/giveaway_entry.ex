defmodule Backend.Giveaways.GiveawayEntry do
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Giveaways.Giveaway
  alias Backend.UserManager.User

  schema "giveaway_entries" do
    belongs_to :giveaway, Giveaway
    belongs_to :user, User
    field :winner, :boolean, default: false

    timestamps()
  end

  def create(giveaway, user) do
    giveaway
    |> Ecto.build_assoc(:giveaway_entries, %{user_id: user.id})
    |> change()
    |> foreign_key_constraint(:giveaway_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:giveaway_id, :user_id])
  end

  @doc false
  def changeset(giveaway_entry \\ %__MODULE__{}, attrs) do
    giveaway_entry
    |> cast(attrs, [:winner, :giveaway_id, :user_id])
    |> foreign_key_constraint(:giveaway_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:giveaway_id, :user_id])
    |> validate_required([:giveaway_id, :user_id])
  end
end
