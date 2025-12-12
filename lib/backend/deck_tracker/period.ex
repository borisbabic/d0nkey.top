defmodule Hearthstone.DeckTracker.Period do
  @moduledoc "Periods for stats"
  use Ecto.Schema
  import Ecto.Changeset

  schema "dt_periods" do
    field(:auto_aggregate, :boolean, default: false)
    field(:display, :string)
    field(:hours_ago, :integer)
    field(:include_in_deck_filters, :boolean, default: false)
    field(:include_in_personal_filters, :boolean, default: false)
    field(:period_end, :naive_datetime)
    field(:period_start, :naive_datetime)
    field(:order_priority, :integer)
    field(:slug, :string)
    field(:type, :string)
    field(:formats, {:array, :integer}, default: Hearthstone.Enums.Format.all_values())

    timestamps()
  end

  @doc false
  def changeset(period, attrs) do
    period
    |> cast(attrs, [
      :slug,
      :display,
      :type,
      :period_start,
      :period_end,
      :hours_ago,
      :order_priority,
      :include_in_personal_filters,
      :include_in_deck_filters,
      :formats,
      :auto_aggregate
    ])
    |> validate_required([
      :slug,
      :display,
      :type,
      :include_in_personal_filters,
      :formats,
      :include_in_deck_filters,
      :auto_aggregate
    ])
  end

  def to_option(%{slug: slug, display: display}), do: {slug, display}

  def use_period_start?(%{type: t, period_start: %NaiveDateTime{}})
      when t in ["patch", "release", "all"],
      do: true

  def use_period_start?(_), do: false

  def use_hours_ago?(%{type: t, hours_ago: ha}) when t in ["rolling"] and is_integer(ha), do: true
  def use_hours_ago?(_), do: false

  @spec start_time(period :: __MODULE__) :: {:ok, NaiveDateTime.t()} | {:error, reason :: atom()}
  def start_time(period) do
    cond do
      use_period_start?(period) ->
        {:ok, period.period_start}

      use_hours_ago?(period) ->
        {:ok, NaiveDateTime.utc_now() |> Timex.shift(hours: -1 * period.hours_ago)}

      true ->
        {:error, :malformed_period_no_start_available}
    end
  end

  @spec end_time(period :: __MODULE__) :: {:ok, NaiveDateTime.t()} | {:error, reason :: atom()}
  def end_time(%{period_end: %NaiveDateTime{} = period_end}), do: {:ok, period_end}
  def end_time(_), do: {:error, :end_not_set}

  @spec end_time_or_now(period :: __MODULE__) :: NaiveDateTime.t()
  def end_time_or_now(period) do
    case end_time(period) do
      {:ok, period} -> period
      _ -> NaiveDateTime.utc_now()
    end
  end

  def future?(%{period_start: %NaiveDateTime{} = period_start}) do
    NaiveDateTime.compare(period_start, NaiveDateTime.utc_now()) == :gt
  end

  def future?(_), do: false

  def size(%{hours_ago: hours_ago}) when is_integer(hours_ago) and hours_ago > 0 do
    hours_ago
  end

  def size(%{period_start: %NaiveDateTime{} = period_start} = period) do
    period_end =
      case period do
        %{period_end: %NaiveDateTime{} = period_end} -> period_end
        _ -> NaiveDateTime.utc_now()
      end

    NaiveDateTime.diff(period_end, period_start, :hour)
  end
end
