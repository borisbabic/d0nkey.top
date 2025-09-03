defmodule Ecto.ErlangTerm do
  use Ecto.Type
  def type, do: :binary
  def cast(value) when is_binary(value), do: {:ok, :erlang.binary_to_term(value)}

  # from_db
  def load(value), do: cast(value)

  # to_db
  def dump(value), do: {:ok, :erlang.term_to_binary(value)}
end
