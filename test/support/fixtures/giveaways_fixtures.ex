defmodule Backend.GiveawaysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Giveaways` context.
  """

  @doc """
  Generate a giveaway.
  """
  def giveaway_fixture(attrs \\ %{}) do
    {:ok, giveaway} =
      attrs
      |> Enum.into(%{
        config: %{},
        deadline: ~N[2226-06-29 22:57:00],
        name: "some name"
      })
      |> Backend.Giveaways.create_giveaway()

    giveaway
  end
end
