defmodule Backend.Feed.FeedItem do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  # 0.9716^24 ~ 0.5, 0.9716^48 ~ 0.25
  @default_decay_rate 0.9716
  @required [:decay_rate, :cumulative_decay, :points, :decayed_points, :value, :type]
  schema "feed_items" do
    field :decay_rate, :float, default: @default_decay_rate
    field :cumulative_decay, :float, default: 1.0
    field :points, :float
    field :decayed_points, :float
    field :value, :string
    field :type, :string
    timestamps()
  end

  @doc false
  def changeset(feed_item, attrs) do
    feed_item
    |> cast(attrs, @required)
    |> ensure_decayed_points(feed_item)
    |> ensure_decay_rate()
    |> validate_required(@required)
  end

  @spec ensure_decayed_points(Ecto.Changeset.t(), __MODULE__) :: Ecto.Changset.t()
  defp ensure_decayed_points(changeset, %{decayed_points: dp}) when is_number(dp), do: changeset

  defp ensure_decayed_points(changeset, _) do
    with :error <- changeset |> fetch_change(:decayed_points),
         {:ok, points} <- changeset |> fetch_change(:points) do
      changeset |> put_change(:decayed_points, points)
    else
      _ -> changeset
    end
  end

  @spec ensure_decay_rate(Ecto.Changeset.t()) :: Ecto.Changset.t()
  defp ensure_decay_rate(changeset) do
    changeset
    |> fetch_change(:decay_rate)
    |> case do
      :error -> changeset |> put_change(:decay_rate, @default_decay_rate)
      {:ok, _} -> changeset
    end
  end
end
