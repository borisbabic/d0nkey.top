defmodule BackendWeb.SharedView do
  use BackendWeb, :view

  def render("datetime.html", %{datetime: maybe_naive}) do
    # always succeeds for Etc/UTC, see h DateTime.from_naive
    {:ok, not_naive} = DateTime.from_naive(maybe_naive, "Etc/UTC")
    timestamp_ms = DateTime.to_unix(not_naive, :millisecond)
    id = :crypto.strong_rand_bytes(42) |> Base.encode64() |> binary_part(0, 42)
    human_readable = Util.datetime_to_presentable_string(maybe_naive)
    render("datetime.html", %{id: id, human_readable: human_readable, timestamp_ms: timestamp_ms})
  end
end
