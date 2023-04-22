defmodule Backend.TournamentStreamsTest do
  use Backend.DataCase

  alias Backend.TournamentStreams

  alias Backend.TournamentStreams.TournamentStream

  @valid_attrs %{
    stream_id: "some stream_id",
    streaming_platform: "some streaming_platform",
    tournament_id: "some tournament_id",
    tournament_source: "some tournament_source"
  }
  @update_attrs %{
    stream_id: "some updated stream_id",
    streaming_platform: "some updated streaming_platform",
    tournament_id: "some updated tournament_id",
    tournament_source: "some updated tournament_source"
  }
  @invalid_attrs %{
    stream_id: nil,
    streaming_platform: nil,
    tournament_id: nil,
    tournament_source: nil
  }

  describe "#paginate_tournament_streams/1" do
    test "returns paginated list of tournament_streams" do
      for _ <- 1..20 do
        tournament_stream_fixture()
      end

      {:ok, %{tournament_streams: tournament_streams} = page} =
        TournamentStreams.paginate_tournament_streams(%{})

      assert length(tournament_streams) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_tournament_streams/0" do
    test "returns all tournament_streams" do
      tournament_stream = tournament_stream_fixture()
      assert TournamentStreams.list_tournament_streams() == [tournament_stream]
    end
  end

  describe "#get_tournament_stream!/1" do
    test "returns the tournament_stream with given id" do
      tournament_stream = tournament_stream_fixture()
      assert TournamentStreams.get_tournament_stream!(tournament_stream.id) == tournament_stream
    end
  end

  describe "#create_tournament_stream/1" do
    test "with valid data creates a tournament_stream" do
      assert {:ok, %TournamentStream{} = tournament_stream} =
               TournamentStreams.create_tournament_stream(@valid_attrs)

      assert tournament_stream.stream_id == "some stream_id"
      assert tournament_stream.streaming_platform == "some streaming_platform"
      assert tournament_stream.tournament_id == "some tournament_id"
      assert tournament_stream.tournament_source == "some tournament_source"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               TournamentStreams.create_tournament_stream(@invalid_attrs)
    end
  end

  describe "#update_tournament_stream/2" do
    test "with valid data updates the tournament_stream" do
      tournament_stream = tournament_stream_fixture()

      assert {:ok, tournament_stream} =
               TournamentStreams.update_tournament_stream(tournament_stream, @update_attrs)

      assert %TournamentStream{} = tournament_stream
      assert tournament_stream.stream_id == "some updated stream_id"
      assert tournament_stream.streaming_platform == "some updated streaming_platform"
      assert tournament_stream.tournament_id == "some updated tournament_id"
      assert tournament_stream.tournament_source == "some updated tournament_source"
    end

    test "with invalid data returns error changeset" do
      tournament_stream = tournament_stream_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TournamentStreams.update_tournament_stream(tournament_stream, @invalid_attrs)

      assert tournament_stream == TournamentStreams.get_tournament_stream!(tournament_stream.id)
    end
  end

  describe "#delete_tournament_stream/1" do
    test "deletes the tournament_stream" do
      tournament_stream = tournament_stream_fixture()

      assert {:ok, %TournamentStream{}} =
               TournamentStreams.delete_tournament_stream(tournament_stream)

      assert_raise Ecto.NoResultsError, fn ->
        TournamentStreams.get_tournament_stream!(tournament_stream.id)
      end
    end
  end

  describe "#change_tournament_stream/1" do
    test "returns a tournament_stream changeset" do
      tournament_stream = tournament_stream_fixture()
      assert %Ecto.Changeset{} = TournamentStreams.change_tournament_stream(tournament_stream)
    end
  end

  def tournament_stream_fixture(attrs \\ %{}) do
    {:ok, tournament_stream} =
      attrs
      |> Enum.into(@valid_attrs)
      |> TournamentStreams.create_tournament_stream()

    tournament_stream
  end
end
