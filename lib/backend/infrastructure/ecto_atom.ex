defmodule Ecto.Atom do
  use Ecto.Type

  def type, do: :string

  def cast(value) when is_binary(value), do: {:ok, String.to_atom(value)}
  def cast(value) when is_atom(value), do: {:ok, value}
  def cast(_), do: :error

  # from_db
  def load(value), do: cast(value)

  # to_db
  def dump(value) when is_atom(value), do: {:ok, Atom.to_string(value)}
  def dump(value) when is_binary(value), do: {:ok, value}
  def dump(_), do: :error
end
