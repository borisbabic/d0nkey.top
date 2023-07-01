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

  def day_start(day = %Date{}, :naive) do
    case NaiveDateTime.new(day.year, day.month, day.day, 0, 0, 0) do
      {:ok, day_start} -> day_start
      _ -> raise "Weird date, couldn't make naive date time"
    end
  end

  def day_end(day = %Date{}, :naive) do
    case NaiveDateTime.new(day.year, day.month, day.day, 23, 59, 59) do
      {:ok, day_start} -> day_start
      _ -> raise "Weird date, couldn't make naive date time"
    end
  end

  def async_map(enum, fun) do
    enum
    |> Enum.map(fn e -> Task.async(fn -> fun.(e) end) end)
    |> Task.await_many()
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

  @doc """
  Checks wether the target NaiveDateTime is within {min, max}
  iex> Util.in_range?(~N[2019-12-01 23:00:00], {~N[2020-03-01 23:00:00], ~N[2022-03-01 00:00:00]})
  false
  iex> Util.in_range?(~N[2020-12-01 23:00:00], {~N[2020-03-01 23:00:00], ~N[2022-03-01 00:00:00]})
  true
  """
  def in_range?(target = %NaiveDateTime{}, {min = %NaiveDateTime{}, max = %NaiveDateTime{}}) do
    NaiveDateTime.compare(target, min) != :lt &&
      NaiveDateTime.compare(target, max) != :gt
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
  def to_int_or_orig(orig), do: to_int(orig, orig)

  @doc """
  iex> Util.vals_to_int_or_orig(%{a: "1", b: "2", c: "3", d: "test"}, [:a, :b, :c, :d])
  %{a: 1, b: 2, c: 3, d: "test"}

  iex> Util.vals_to_int_or_orig(%{a: "1", b: %{c: "3"}, d: "test"}, [:a, [:b, :c]])
  %{a: 1, b: %{c: 3}, d: "test"}

  """
  @spec vals_to_int_or_orig(Access.t(), [term() | [term()]]) :: Access.t()
  def vals_to_int_or_orig(orig, keys_or_lists) do
    Enum.reduce(keys_or_lists, orig, fn keys, carry ->
      update_in(carry, to_list(keys), &to_int_or_orig/1)
    end)
  end

  @doc """
  Transform to an integer while ignoring the binary remainder or returns the fallback

  ## Example
  iex> Util.to_int("hello", 45)
  45
  iex> Util.to_int("-1", 45)
  -1
  iex> Util.to_int("-1.45", 45)
  -1
  """
  def to_int(<<int_or_not::binary>>, fallback) do
    case Integer.parse(int_or_not) do
      {int, _rem} -> int
      _ -> fallback
    end
  end

  def to_int(_, fallback), do: fallback

  @doc """
  Takes and {:ok,_} | {:error, _ } and returns the value on :ok and nil on :error
  """
  @spec nilify({:ok | :error, any()}) :: any() | nil
  def nilify({:ok, val}), do: val
  def nilify({:error, _reason}), do: nil

  @doc """
  Takes and {:ok, value} | {:error, reason} and returns the value on :ok and raises the reason on :error
  """
  @spec bangify({:ok | :error, any()}) :: any()
  def bangify({:ok, val}), do: val
  def bangify({:error, reason}), do: raise(reason)
  def bangify(:error), do: raise("Unknown error")

  def ok!(thing), do: bangify(thing)

  @doc """
  Either returns the list or returns a new list with a single element
  """
  def to_list(list) when is_list(list), do: list
  def to_list(not_list), do: [not_list]

  @doc """
  iex> Util.percent(141324,0)
  0.0
  iex> Util.percent(20,50)
  40.0
  """
  def percent(_, 0), do: 0.0
  def percent(num, total), do: 100 * num / total

  def update_from_to_params(params, {from = %Date{}, to = %Date{}}) do
    Map.merge(params, %{"from" => Date.to_iso8601(from), "to" => Date.to_iso8601(to)})
  end

  def current_week() do
    Date.utc_today()
    |> Date.to_erl()
    |> :calendar.iso_week_number()
  end

  def get_range(:year) do
    %{year: year} = Date.utc_today()
    {Date.new(year, 1, 1) |> bangify(), Date.new(year, 12, 31) |> bangify()}
  end

  def get_range(:month) do
    today = %{year: year, month: month, day: _} = Date.utc_today()

    start_of_month =
      case Date.new(year, month, 1) do
        {:ok, date} -> date
        # this should never happen
        {:error, reason} -> throw(reason)
      end

    end_of_month = Date.add(start_of_month, Date.days_in_month(today) - 1)
    {start_of_month, end_of_month}
  end

  def get_range(:week), do: get_range(:week, 1)

  def get_range(:week, day_in_week) when is_integer(day_in_week) do
    start_time = get_latest_day(day_in_week)
    end_time = Date.add(start_time, 6)
    {start_time, end_time}
  end

  def get_latest_day(day_in_week) when is_integer(day_in_week) do
    %{year: year, month: month, day: day} = now = Date.utc_today()
    day_of_the_week = :calendar.day_of_the_week(year, month, day)
    days_to_subtract = 0 - rem(day_of_the_week + (7 - day_in_week), 7)
    Date.add(now, days_to_subtract)
  end

  def naive_date_time_or_nil(nil), do: nil

  def naive_date_time_or_nil(val) do
    val
    |> NaiveDateTime.from_iso8601()
    |> nilify
  end

  def gen_html_id() do
    # A as the first to ensure it starts with a non digit
    min = String.to_integer("A0000000000000000000000", 36)

    String.to_integer("ZZZZZZZZZZZZZZZZZZZZZZZ", 36)
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end

  @doc """
  iex> Util.get_percentile_unsorted(10, [500, 100, 200, 300])
  0.0
  iex> Util.get_percentile_unsorted(1000, [500, 100, 200, 300])
  100.0
  iex> Util.get_percentile_unsorted(1000, [6000, 200, 300, 2000, 5000])
  40.0
  """
  def get_percentile_unsorted(target, all, get_val \\ &Util.id/1) do
    sorted_all = all |> Enum.sort_by(get_val, :asc)
    get_percentile(target, sorted_all, get_val)
  end

  @doc """
  iex> Util.get_percentile(10, [100, 200, 300])
  0.0
  iex> Util.get_percentile(1000, [100, 200, 300])
  100.0
  iex> Util.get_percentile(1000, [100, 200, 300, 2000, 5000])
  60.0
  """
  def get_percentile(target, all, get_val \\ &Util.id/1) do
    val = get_val.(target)

    num_lower =
      all
      |> Enum.sort_by(get_val, :asc)
      |> Enum.take_while(fn a -> get_val.(a) < val end)
      |> Enum.count()

    num_lower * 100 / (all |> Enum.count())
  end

  def get_month_name(%{month: month}), do: get_month_name(month)

  @doc """
  Gets the month name

  ## Example
    iex> Util.get_month_name(~D[1990-06-15])
    :June
    iex> Util.get_month_name(12)
    :December
    iex> Util.get_month_name(1)
    :January
  """
  @spec get_month_name(integer | Date.t() | DateTime.t()) :: atom | String.t()
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_month_name(month) do
    case month do
      1 -> :January
      2 -> :February
      3 -> :March
      4 -> :April
      5 -> :May
      6 -> :June
      7 -> :July
      8 -> :August
      9 -> :September
      10 -> :October
      11 -> :November
      12 -> :December
      x -> to_string(x)
    end
  end

  @spec get_month_number(String.t()) :: {:ok, integer()} | {:error, String.t()}
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_month_number(month) do
    case month do
      "January" -> {:ok, 1}
      "February" -> {:ok, 2}
      "March" -> {:ok, 3}
      "April" -> {:ok, 4}
      "May" -> {:ok, 5}
      "June" -> {:ok, 6}
      "July" -> {:ok, 7}
      "August" -> {:ok, 8}
      "September" -> {:ok, 9}
      "October" -> {:ok, 10}
      "November" -> {:ok, 11}
      "December" -> {:ok, 12}
      _ -> {:error, "Unknown month name #{month}"}
    end
  end

  @doc """
  Gets the middle/median member in the list
  iex> Util.median([1,2,3])
  2
  iex> Util.median([1,2,3,5,6,7])
  5
  """
  def median(sortable_list),
    do: sortable_list |> Enum.sort() |> Enum.at(Enum.count(sortable_list) |> div(2))

  def get_country_code(name) do
    with %{alpha2: code} <- get_country(name) do
      code
    end
  end

  def get_country(name) do
    with nil <- Countriex.get_by(:name, name) do
      Countriex.all()
      |> Enum.find(&(name in &1.unofficial_names))
    end
  end

  def get_country_name(nil), do: nil

  def get_country_name(cc) do
    country = Countriex.get_by(:alpha2, cc)

    if country != nil do
      country.name
    else
      nil
    end
  end

  @doc """
  Only call a genserver if it's up, if not return a default value

  ## Example
  iex> Util.gs_call_if_up(:this_totally_does_not_exist, :important_func, "blabla")
  "blabla"

  """
  def gs_call_if_up(name, call, if_down \\ nil) do
    if GenServer.whereis(name) == nil do
      if_down
    else
      GenServer.call(name, call)
    end
  end

  def ets_lookup(table, key, default \\ nil)
  def ets_lookup(:undefined, _, default), do: default

  def ets_lookup(table, key, default) do
    case :ets.lookup(table, key) do
      [{found_key, value}] when found_key == key -> value
      [] -> default
      other -> other
    end
  end

  def or_nil({:ok, thing}), do: thing
  def or_nil({:error, _}), do: nil

  @doc """
  Like Enum.map except it expects and handles error tuples from the mapper function
  It aborts at the first {:error, _} tuple returning that tuple
  If the mapper function always returns {:ok, value} this will return {:ok, [values]}

  ## Example
  iex> Util.map_abort_on_error(["1999-12-31", "1900-01-01"], &Date.from_iso8601/1)
  {:ok, [~D[1999-12-31], ~D[1900-01-01]]}

  iex> Util.map_abort_on_error(["2021-12-57", "adgfqwt"], &Date.from_iso8601/1)
  {:error, :invalid_date}

  iex> Util.map_abort_on_error(["adgfqwt", "2021-12-57"], &Date.from_iso8601/1)
  {:error, :invalid_format}

  iex> Util.map_abort_on_error([:apples, :oranges], &to_string/1)
  {:error, :invalid_mapper_function_return}
  """
  @spec map_abort_on_error(any(), (any() -> {:ok, any()} | {:error, any()})) ::
          {:ok, list()} | {:error, any()}
  def map_abort_on_error(enum, map_fun), do: do_map_abort_on_error(enum, map_fun, {:ok, []})

  defp do_map_abort_on_error([], _map_fun, {:ok, values}), do: {:ok, values |> Enum.reverse()}

  defp do_map_abort_on_error([current | rest], map_fun, _carry = {:ok, cards}) do
    case map_fun.(current) do
      {:ok, mapped} -> do_map_abort_on_error(rest, map_fun, {:ok, [mapped | cards]})
      e = {:error, _} -> e
      _ -> {:error, :invalid_mapper_function_return}
    end
  end

  defp prepend_non_nil(list, nil), do: list
  defp prepend_non_nil(list, val) when is_list(list), do: [val | list]
  defp prepend_non_nil(list, nil, to_prepend), do: list
  defp prepend_non_nil(list, _to_check, to_prepend) when is_list(list), do: [to_prepend | list]

  @doc """
  Unpacks something that might be in a list of might already be out of it
  iex > 
  """
  @spec unpack(any() | [any()]) :: any()
  def unpack([thing]), do: thing
  def unpack(thing), do: thing
end
