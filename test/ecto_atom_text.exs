defmodule Ecto.AtomTest do
  use ExUnit.Case
  doctest Ecto.Atom

  test "cast atom" do
    assert Ecto.Atom.cast(:atom) == {:ok, :atom}
  end

  test "cast with failure" do
    assert Ecto.Atom.cast(1) == :error
  end

  test "load from string" do
    assert Ecto.Atom.load("some string") == {:ok, :"some string"}
  end

  test "load dumped value" do
    {:ok, dumped} = Ecto.Atom.dump(:atom)
    assert Ecto.Atom.load(dumped) == {:ok, :atom}
  end

  test "dump :atom" do
    assert Ecto.Atom.dump(:atom) == {:ok, "atom"}
  end

  test "dump string" do
    assert Ecto.Atom.dump("string") == {:ok, "string"}
  end

  test "dump number" do
    assert Ecto.Atom.dump(1) == :error
  end
end
