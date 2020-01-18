defmodule Util do
  @moduledoc """
    Generic utility functions
  """

  @doc """
  Makes all numbers fit into cycles of 1..12

  ## Example
    iex> Util.normalize_month(0)
    12
    iex> Util.normalize_month(-2)
    10
    iex> Util.normalize_month(15)
    3
    iex> Util.normalize_month(7)
    7
  """
  @spec normalize_month(integer) :: integer
  def normalize_month(month) do
    place_in_cycle(month, 1, 12)
  end

  @doc """
    Makes a number fit into a cycle of numbers

    ## Example
      iex> Util.place_in_cycle(-2, 1, 12)
      10
      iex> Util.place_in_cycle(-7, 5, 15)
      15
      iex> Util.place_in_cycle(29, 3, 14)
      5
  """
  @spec place_in_cycle(integer, integer, integer) :: integer
  def place_in_cycle(number, min, max) when max > min do
    length = max + 1 - min
    rem(rem(number - min, length) + length, length) + min
  end

  @doc """
  Transforms the datetime into a displayable string

  Example
  iex> Util.datetime_to_presentable_string(~N[2019-12-01 23:00:00])
  "2019-12-01 23:00:00"

  """
  @spec datetime_to_presentable_string(Calendar.datetime()) :: String.t()
  def datetime_to_presentable_string(datetime) do
    datetime
    |> NaiveDateTime.to_iso8601()
    |> String.splitter(["Z", ".", "z"])
    |> Enum.at(0)
    |> String.replace("T", " ")
  end

  def human_diff(later, earlier) do
    diff = NaiveDateTime.diff(later, earlier, :second)
    hours = div(diff, 60 * 60) |> pad_time_element()
    minutes_and_seconds = rem(diff, 60 * 60)
    minutes = div(minutes_and_seconds, 60) |> pad_time_element()
    seconds = rem(minutes_and_seconds, 60) |> pad_time_element()
    "#{hours}:#{minutes}:#{seconds}"
  end

  @doc """
  Converts an integer into a string padded to represent time
  ## Example
  iex> pad_time_element(4)
  "04"
  iex> pad_time_element(12)
  "12"
  iex> pad_time_element(666)
  "666"
  """
  @spec pad_time_element(integer()) :: String.t()
  def pad_time_element(integer) do
    String.pad_leading(to_string(integer), 2, "0")
  end
end
