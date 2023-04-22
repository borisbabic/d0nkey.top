defmodule Backend.TournamentStreamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.TournamentStreams` context.
  """

  @doc """
  Generate a tournament_stream.
  """
  def tournament_stream_fixture(attrs \\ %{}) do
    {:ok, tournament_stream} =
      attrs
      |> Enum.into(%{
        stream_id: "some stream_id",
        streaming_platform: "some streaming_platform",
        tournament_id: "some tournament_id",
        tournament_source: "some tournament_source"
      })
      |> Backend.TournamentStreams.create_tournament_stream()

    tournament_stream
  end
end
