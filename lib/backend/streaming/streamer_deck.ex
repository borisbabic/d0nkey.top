defmodule Backend.Streaming.StreamerDeck do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Deck
  alias Backend.Streaming.Streamer

  @required [:first_played, :last_played]
  @not_required [:best_rank, :best_legend_rank]
  @primary_key false
  schema "streamer_deck" do
    belongs_to :deck, Deck, primary_key: true
    belongs_to :streamer, Streamer, primary_key: true
    field :best_rank, :integer
    field :best_legend_rank, :integer
    field :first_played, :utc_datetime
    field :last_played, :utc_datetime
    timestamps()
  end

  @doc false
  defp non_assoc(), do: @required ++ @not_required

  @doc false
  def changeset(c = %{first_played: fp}, a) when not is_nil(fp), do: update(c, a)
  def changeset(c, a), do: create(c, a)

  @doc false
  def update(c, a) do
    IO.inspect(c)
    IO.inspect(a)

    c
    |> cast(a, [:last_played, :best_rank, :best_legend_rank])
    |> validate_required([:last_played, :best_rank, :best_legend_rank])
    |> IO.inspect()
  end

  @doc false
  def create(c, a) do
    c
    |> cast(a, non_assoc())
    |> validate_required(@required)
    |> put_assoc(:deck, a.deck)
    |> put_assoc(:streamer, a.streamer)
    |> foreign_key_checks()
  end

  def foreign_key_checks(c) do
    c
    |> foreign_key_constraint(:deck)
    |> foreign_key_constraint(:streamer)
  end
end
