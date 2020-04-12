defmodule Backend.Battlefy.Util do
  @moduledoc false

  @spec parse_date(String.t()) :: NaiveDateTime.t()
  def parse_date(date) when is_binary(date) do
    NaiveDateTime.from_iso8601!(date)
  end

  @spec parse_date(any) :: nil
  def parse_date(_) do
    nil
  end
end
