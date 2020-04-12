defmodule Backend.FifoSet do
  @moduledoc """
    A set with a fixed length that automatically removes the oldest entries when new ones come in
  """
  use TypedStruct

  typedstruct enforce: true do
    field :max_length, integer
    field :entries, list(), default: []
  end

  def add(set, <<key::binary>>, value) do
    add(set, String.to_atom(key), value)
  end

  def add(set = %{max_length: max_length, entries: entries}, key, value)
      when length(entries) < max_length do
    _add(set, max_length, entries, key, value)
  end

  def add(set = %{max_length: max_length, entries: [_throw_away, entries]}, key, value)
      when length(entries) == max_length do
    _add(set, max_length, entries, key, value)
  end

  defp _add(set, max_length, entries, key, value) do
    if entries[key] do
      set
    else
      %{
        max_length: max_length,
        entries: entries ++ [{key, value}]
      }
    end
  end

  def to_list(set) do
    set.entries |> Keyword.values()
  end

  def get(set, <<key::binary>>) do
    get(set, String.to_atom(key))
  end

  def get(set, key) do
    set.entries[key]
  end

  def has?(set, key) do
    nil != set |> get(key)
  end
end
