defmodule Backend.Grandmasters.PromotionRanking do
  @moduledoc false
  use TypedStruct
  alias Backend.Grandmasters.TourStopPromotionPoints, as: TSPoints

  alias __MODULE__

  typedstruct enforce: true do
    field :player, String.t()
    field :total, integer()
    field :per_ts, TSPoints.t()
  end

  def merge_ts(ts_points_list = [%{player: player} | _]) do
    total = ts_points_list |> Enum.map(& &1.points) |> Enum.sum()

    %PromotionRanking{
      player: player,
      total: total,
      per_ts: ts_points_list
    }
  end

  def sort(rankings), do: Enum.sort(rankings, &compare/2)

  def compare(%{total: a_tot, per_ts: a_per_ts}, %{total: b_tot, per_ts: b_per_ts})
      when a_tot == b_tot do
    compare_ts_points(a_per_ts, b_per_ts)
  end

  def compare(%{total: a_tot}, %{total: b_tot}), do: a_tot > b_tot
  defp compare_ts_points(a, b), do: compare_lists(TSPoints.tiebreaks(a), TSPoints.tiebreaks(b))
  def compare_lists(_list, []), do: true
  def compare_lists([], _list), do: false

  def compare_lists([a_val | a_rem], [b_val | b_rem]) when a_val == b_val,
    do: compare_lists(a_rem, b_rem)

  def compare_lists([a_val | _], [b_val | _]), do: a_val < b_val
end

defmodule Backend.Grandmasters.TourStopPromotionPoints do
  @moduledoc false
  use TypedStruct
  alias __MODULE__

  typedstruct enforce: true do
    field :player, String.t()
    field :tour_stop, atom()
    field :points, integer()
    field :tiebreak, integer()
  end

  @spec sort([TourStopPromotionPoints.t()]) :: [integer()]
  def tiebreaks(ts_points) when is_list(ts_points) do
    ts_points |> Enum.map(& &1.tiebreak) |> Enum.sort(:asc)
  end

  @spec sort([TourStopPromotionPoints.t()]) :: [TourStopPromotionPoints.t()]
  def sort(ts_points) do
    ts_points
    |> Enum.sort_by(& &1.tiebreak, :asc)
    |> Enum.sort_by(& &1.points, :desc)
  end
end
