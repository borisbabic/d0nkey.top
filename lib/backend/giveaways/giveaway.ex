defmodule Backend.Giveaways.Giveaway do
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Giveaways.GiveawayEntry
  alias Backend.UserManager.User

  schema "giveaways" do
    field :name, :string
    field :description, :string, default: nil
    field :config, :map
    field :deadline, :naive_datetime
    field :number_of_winners, :integer, default: 1
    belongs_to :creator, User

    many_to_many(:pool, GiveawayEntry,
      join_through: "giveaway_entries",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(giveaway, attrs) do
    giveaway
    |> cast(attrs, [:name, :config, :deadline, :creator_id, :number_of_winners, :description])
    |> validate_required([:name, :deadline, :creator_id])
  end
end
