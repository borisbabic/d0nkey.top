defmodule Dreamhack do
  @current_info [
    {:Americas, "60f57b1999c0bc25ab5f00fc", ~N[2021-07-28 18:00:00], ~N[2021-08-03 04:20:00],
     "/fantasy/leagues/join/2f3e690b-7170-47d4-8239-195ec8fa535f"},
    {:"Asia-Pacific", "60f53b7f2a52fc4c16f2c2b9", ~N[2021-07-26 07:00:00],
     ~N[2021-08-03 04:20:00], "/fantasy/leagues/join/9b2b6d75-07cf-4a16-a519-0349ca247b5f"},
    {:Europe, "60f57a24a45434114a57fbed", ~N[2021-07-27 12:00:00], ~N[2021-08-03 04:20:00],
     "/fantasy/leagues/join/4516e7b1-dfc8-46a1-a984-a47e5fb87038"}
  ]
  def current() do
    now = NaiveDateTime.utc_now()

    @current_info
    |> Enum.filter(fn {_, _, start, end_time, _} ->
      NaiveDateTime.compare(start, now) == :lt &&
        NaiveDateTime.compare(end_time, now) == :gt
    end)
    |> Enum.map(fn {tour, id, _, _, _} ->
      {tour, id}
    end)
  end

  def current_fantasy() do
    now = NaiveDateTime.utc_now()

    @current_info
    |> Enum.filter(fn {_, _, start, _, _} ->
      NaiveDateTime.compare(start, now) == :gt
    end)
    |> Enum.map(fn {tour, _, _, _, fantasy_link} ->
      {tour, fantasy_link}
    end)
  end
end
