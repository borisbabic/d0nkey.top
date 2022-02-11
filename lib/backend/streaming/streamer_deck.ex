defmodule Backend.Streaming.StreamerDeck do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Deck
  alias Backend.Streaming.Streamer

  @required [:first_played, :last_played]
  @not_required [
    :best_rank,
    :best_legend_rank,
    :worst_legend_rank,
    :latest_legend_rank,
    :game_type,
    :minutes_played
  ]
  @primary_key false
  schema "streamer_deck" do
    belongs_to :deck, Deck, primary_key: true, on_replace: :update
    belongs_to :streamer, Streamer, primary_key: true
    field :best_rank, :integer
    field :best_legend_rank, :integer
    field :first_played, :utc_datetime
    field :last_played, :utc_datetime
    field :worst_legend_rank, :integer
    field :latest_legend_rank, :integer
    field :minutes_played, :integer, default: 1
    field :game_type, :integer, nullable: true
    field :wins, :integer, default: 0
    field :losses, :integer, default: 0
    timestamps()
  end

  @doc false
  defp non_assoc(), do: @required ++ @not_required

  @doc false
  def changeset(c = %{first_played: fp}, a) when not is_nil(fp), do: update(c, a)
  def changeset(c, a), do: create(c, a)

  @doc false
  def update(c, a) do
    c
    |> cast(a, [
      :last_played,
      :best_rank,
      :best_legend_rank,
      :deck_id,
      :worst_legend_rank,
      :latest_legend_rank,
      :minutes_played
    ])
    |> cast_assoc(:deck)
    |> add_wins_losses(a)
    |> validate_required([:last_played, :best_rank, :best_legend_rank])
  end

  def add_wins_losses(cs, %{result: :win}) do
    old_wins = cs |> fetch_field!(:wins)
    cs |> put_change(:wins, old_wins + 1)
  end

  def add_wins_losses(cs, %{result: :loss}) do
    old_wins = cs |> fetch_field!(:losses)
    cs |> put_change(:losses, old_wins + 1)
  end

  def add_wins_losses(cs, _attrs) do
    cs
  end

  @doc false
  def create(c, a) do
    c
    |> cast(a, non_assoc())
    |> validate_required(@required)
    |> set_deck(a)
    |> set_streamer(a)
    |> add_wins_losses(a)
  end

  defp set_deck(c, %{deck: deck}) do
    c
    |> put_assoc(:deck, deck)
    |> foreign_key_constraint(:deck)
  end

  defp set_deck(c, _), do: c

  defp set_streamer(c, %{streamer: streamer}) do
    c
    |> put_assoc(:streamer, streamer)
    |> foreign_key_constraint(:streamer)
  end

  defp set_streamer(c, _), do: c

  def winrate(%{wins: wins, losses: losses}) when wins + losses > 0 do
    (wins) / (wins + losses)
  end

  def winrate(_), do: nil


end
