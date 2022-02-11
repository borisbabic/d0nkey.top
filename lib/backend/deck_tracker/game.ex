defmodule Hearthstone.DeckTracker.Game do
  @moduledoc """
  A game from the decktracker
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker.Source
  alias Backend.Api.ApiUser

  schema "dt_games" do
    field :player_btag, :string
    field :player_rank, :integer
    field :player_legend_rank, :integer
    field :player_class, :string
    belongs_to :player_deck, Deck

    field :opponent_btag, :string
    field :opponent_rank, :integer
    field :opponent_legend_rank, :integer
    field :opponent_class, :string
    belongs_to :opponent_deck, Deck

    field :game_id, :string
    field :game_type, :integer
    field :format, :integer
    field :status, Ecto.Enum, values: [:win, :loss, :draw, :in_progress, :unknown]
    field :region, Ecto.Enum, values: [:AM, :AP, :EU, :CN, :unknown]
    field :duration, :integer
    field :turns, :integer
    field :replay_url, :string, default: nil

    field :public, :boolean, default: false
    belongs_to :source, Source

    belongs_to :created_by, ApiUser
    timestamps()
  end

  @doc false
  def changeset(game = %{game_id: game_id}, attrs) when is_binary(game_id) do
    game
    |> cast(attrs, [:status, :duration, :turns, :player_class, :opponent_class])
    |> unique_constraint(:game_id)
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [
      :player_btag,
      :player_rank,
      :player_legend_rank,
      :player_class,
      :opponent_btag,
      :opponent_rank,
      :opponent_legend_rank,
      :opponent_class,
      :game_id,
      :game_type,
      :format,
      :status,
      :region,
      :public,
      :replay_url,
      :duration,
      :turns
    ])
    |> fix_rank(:player_rank, :player_legend_rank)
    |> fix_rank(:opponent_rank, :opponent_legend_rank)
    |> put_assoc_from_attrs(attrs, :player_deck)
    |> put_assoc_from_attrs(attrs, :opponent_deck)
    |> put_assoc_from_attrs(attrs, :created_by)
    |> put_assoc_from_attrs(attrs, :source)
    |> validate_required([
      :player_btag,
      :status,
      :region,
      :game_id
    ])
    |> unique_constraint(:game_id)
  end

  defp fix_rank(cs, rank_attr, legend_attr) do
    current_rank_val = get_change(cs, rank_attr)
    current_legend_val = get_change(cs, legend_attr)
    {rank, legend} = ranks(current_rank_val, current_legend_val)
    cs
    |> put_change(rank_attr, rank)
    |> put_change(legend_attr, legend)
  end

  defp ranks(nil, nil), do: {0, 0}
  defp ranks(_, legend_rank) when is_integer(legend_rank) and legend_rank > 0 do
    {51, legend_rank}
  end
  defp ranks(rank, legend_rank) do
    {rank, legend_rank}
  end

  defp put_assoc_from_attrs(cs, attrs, attr) do
    with nil <- Map.get(attrs, attr),
         nil <- Map.get(attrs, to_string(attr)) do
      cs
    else
      val -> put_assoc(cs, attr, val)
    end
  end
end
