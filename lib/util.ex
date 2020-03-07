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
    human_duration(diff)
  end

  def human_duration(dur) when is_float(dur) do
    human_duration(round(dur))
  end

  def human_duration(dur) do
    hours = div(dur, 60 * 60) |> pad_time_element()
    minutes_and_seconds = rem(dur, 60 * 60)
    minutes = div(minutes_and_seconds, 60) |> pad_time_element()
    seconds = rem(minutes_and_seconds, 60) |> pad_time_element()
    "#{hours}:#{minutes}:#{seconds}"
  end

  @doc """
  Converts an integer into a string padded to represent time
  ## Example
  iex> Util.pad_time_element(4)
  "04"
  iex> Util.pad_time_element(12)
  "12"
  iex> Util.pad_time_element(666)
  "666"
  """
  @spec pad_time_element(integer()) :: String.t()
  def pad_time_element(integer) do
    String.pad_leading(to_string(integer), 2, "0")
  end

  def reject_keys(target, keys) do
    Enum.reject(target, fn {k, _v} -> Enum.member?(keys, k) end)
  end

  # def map_kv!(map, key_mapper_list) do
  #   case map_kv(map, key_mapper_list) do
  #     {:error, reason} -> throw reason
  #     success -> success
  #   end
  # end

  # def map_kv(map, key_mapper_list) do
  #   missing_keys = Map.keys(key_mapper_list) -- Map.keys(map)
  #   if missing_keys != [] do
  #     {:error, "Missing keys from map: #{Enum.join(missing_keys, " ")}"}
  #   end
  #   mapped = key_mapper_list
  #   |> Enum.map(fn {key, mapper} ->
  #     case()

  #     {key, mapper.(map[key])}
  #   end)
  #   {:ok, mapped}
  # end

  # def map_kv(map, key_mapper_list, struct) do
  #   struct(struct, map |> map_kv(key_mapper_list))
  # end
  # def map_kv!(map, key_mapper_list, struct) do
  #   struct(struct, map |> map_kv!(key_mapper_list))
  # end

  def update_map(map, key_updater_map) do
    key_updater_map
    |> Enum.reduce(map, fn {key, updater}, acc ->
      Map.put(acc, key, updater.(map[key]))
    end)
  end

  def update_map_to_struct(map, key_updater_list, struct) do
    struct(struct, update_map(map, key_updater_list))
  end

  def get(from, key, opts \\ [default: nil, atoms: :convert])

  def get(from, key, opts) when is_binary(key) do
    atom_val =
      case opts[:atoms] do
        :convert -> String.to_atom(key)
        :convert_existing -> String.to_existing_atom(key)
        _ -> nil
      end

    case {atom_val, from} do
      {_, %{^key => value}} -> value
      {k, _} when is_atom(k) -> get(from, key, opts)
      _ -> opts[:default]
    end
  end

  def get(from, key, opts) when is_atom(key) do
    string_key = to_string(key)

    case from do
      [_ | _] -> from[key]
      %{^key => value} -> value
      %{^string_key => value} -> value
      _ -> opts[:default]
    end
  end

  @spec id(any) :: any
  def id(x), do: x

  @doc """
  Get's the date range before this one with the same length

  ## Example
  iex> Util.get_previous_range({~D[2020-01-01], ~D[2020-01-07]})
  {~D[2019-12-25], ~D[2019-12-31]}
  """
  def get_previous_range({%Date{} = from, %Date{} = to}) do
    new_to = Date.add(from, -1)
    diff = Date.diff(from, to)
    new_from = Date.add(new_to, diff)
    {new_from, new_to}
  end

  @doc """
  Get's the date range after this one with the same length

  ## Example
  iex> Util.get_following_range({~D[2020-01-01], ~D[2020-01-07]})
  {~D[2020-01-08], ~D[2020-01-14]}
  """
  def get_following_range({%Date{} = from, %Date{} = to}) do
    new_from = Date.add(to, 1)
    diff = Date.diff(to, from)
    new_to = Date.add(new_from, diff)
    {new_from, new_to}
  end

  @doc """
  Get's the date ranges before after this one with the same length

  ## Example
  iex> Util.get_surrounding_ranges({~D[2020-01-01], ~D[2020-01-07]})
  {{~D[2019-12-25], ~D[2019-12-31]}, {~D[2020-01-08], ~D[2020-01-14]}}
  """
  def get_surrounding_ranges(range = {%Date{} = _from, %Date{} = _to}) do
    {get_previous_range(range), get_following_range(range)}
  end

  @doc """
  Transform to an integer while ignoring the binary remainder or returns the original string

  ## Example
  iex> Util.to_int_or_orig("hello")
  "hello"
  iex> Util.to_int_or_orig("-1")
  -1
  iex> Util.to_int_or_orig("-1.45")
  -1
  """
  def to_int_or_orig(int_or_not) do
    case Integer.parse(int_or_not) do
      {int, _rem} -> int
      _ -> int_or_not
    end
  end

  @doc """
  Either returns the list or returns a new list with a single element
  """
  def to_list(list) when is_list(list), do: list
  def to_list(not_list), do: [not_list]
end
