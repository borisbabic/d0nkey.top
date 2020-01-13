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
    |> DateTime.to_iso8601()
    |> String.splitter(["Z", ".", "z"])
    |> Enum.at(0)
    |> String.replace("T", " ")
  end
end
