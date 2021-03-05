defmodule Backend.Fantasy.League do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User

  schema "leagues" do
    field :competition, :string
    field :competition_type, :string
    field :max_teams, :integer
    field :name, :string
    field :point_system, :string
    field :roster_size, :integer
    belongs_to :owner, User, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(league, attrs) do
    league
    |> cast(attrs, [
      :name,
      :competition,
      :competition_type,
      :point_system,
      :max_teams,
      :roster_size
    ])
    |> validate_required([
      :name,
      :competition,
      :competition_type,
      :point_system,
      :max_teams,
      :roster_size
    ])
  end
end
