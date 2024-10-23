defmodule Hearthstone.DeckTracker.Game do
  @moduledoc """
  A game from the decktracker
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker.RawPlayerCardStats
  alias Hearthstone.DeckTracker.Source
  alias Hearthstone.DeckTracker.CardGameTally
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
    field :player_has_coin, :boolean, default: nil
    has_one(:raw_player_card_stats, RawPlayerCardStats)
    field :replay_url, :string, default: nil

    field :public, :boolean, default: false
    belongs_to :source, Source
    has_many :card_tallies, CardGameTally, on_replace: :delete_if_exists

    belongs_to :created_by, ApiUser
    timestamps()
  end

  @doc false
  def changeset(game = %{game_id: game_id}, attrs) when is_binary(game_id) do
    game
    |> Backend.Repo.preload([:raw_player_card_stats, :card_tallies])
    |> cast(attrs, [
      :status,
      :duration,
      :turns,
      :player_class,
      :opponent_class,
      :replay_url,
      :player_has_coin,
      :region,
      :opponent_rank,
      :opponent_legend_rank,
      :public
    ])
    |> build_raw_player_card_stats(attrs)
    |> build_card_tallies(attrs)
    |> unique_constraint(:game_id)
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> Backend.Repo.preload(:raw_player_card_stats)
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
      :player_has_coin,
      :duration,
      :turns
    ])
    |> build_raw_player_card_stats(attrs)
    |> build_card_tallies(attrs)
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
    |> cast(attrs, [:inserted_at])
  end

  defp build_raw_player_card_stats(cs, %{"raw_player_card_stats" => _raw}) do
    cs
    |> cast_assoc(:raw_player_card_stats)
  end

  defp build_raw_player_card_stats(cs, _attrs) do
    cs
  end

  defp build_card_tallies(cs, %{"card_tallies" => _}) do
    cs
    |> cast_assoc(:card_tallies)
  end

  defp build_card_tallies(cs, _attrs) do
    cs
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

  def player_rank_text(%{player_legend_rank: legend}) when legend > 0 do
    "##{legend} Legend"
  end

  def player_rank_text(%{player_rank: rank}) when rank > 0 do
    case convert_rank(rank) do
      {level, num} -> "#{level} #{num}"
      level -> "#{level}"
    end
  end

  def player_rank_text(_), do: "Unknown"

  def convert_rank(num) when is_integer(num) and num > 0 do
    rank = 10 - rem(num - 1, 10)

    case div(num - 1, 10) do
      0 -> {:Bronze, rank}
      1 -> {:Silver, rank}
      2 -> {:Gold, rank}
      3 -> {:Platinum, rank}
      4 -> {:Diamond, rank}
      5 -> :Legend
      _ -> :Unknown
    end
  end

  def convert_rank(:Legend), do: 51

  def convert_rank({level, rank}) do
    level_part =
      10 *
        case level do
          :Bronze -> 0
          :Silver -> 1
          :Gold -> 2
          :Platinum -> 3
          :Diamond -> 4
        end

    level_part - rank + 11
  end

  def convert_rank(nil), do: nil
end
