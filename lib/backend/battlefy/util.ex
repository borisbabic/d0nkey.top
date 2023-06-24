defmodule Backend.Battlefy.Util do
  @moduledoc false

  @spec parse_date(String.t() | nil) :: NaiveDateTime.t() | nil
  def parse_date(date) when is_binary(date) do
    NaiveDateTime.from_iso8601!(date)
  end

  def parse_date(_) do
    nil
  end
end
