defmodule Hearthstone.DeckTrackerTest do
  use Backend.DataCase
  alias Hearthstone.DeckTracker

  describe "games" do
    alias Hearthstone.DeckTracker.Game
    alias Hearthstone.DeckTracker.GameDto
    alias Hearthstone.DeckTracker.PlayerDto
    alias Hearthstone.DeckTracker.RawPlayerCardStats

    @valid_dto %GameDto{
      player: %PlayerDto{
        battletag: "D0nkey#2470",
        rank: 51,
        legend_rank: 512,
        deckcode:
          "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      },
      opponent: %PlayerDto{
        battletag: "BlaBla#14314",
        rank: 50,
        legend_rank: nil
      },
      game_id: "first_game",
      game_type: 7,
      format: 2,
      region: "KR"
    }
    @minimal_dto %GameDto{
      player: %PlayerDto{
        battletag: "D0nkey#2470",
        rank: nil,
        legend_rank: nil,
        deckcode:
          "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      },
      opponent: %PlayerDto{
        battletag: nil,
        rank: nil,
        legend_rank: nil
      },
      result: "WON",
      game_id: "bla bla car",
      game_type: 7,
      format: 2
    }

    @with_known_card_stats %GameDto{
      player: %PlayerDto{
        battletag: "D0nkey#2470",
        rank: nil,
        legend_rank: nil,
        cards_in_hand_after_mulligan: [%{card_dbf_id: 74097, kept: false}],
        cards_drawn_from_initial_deck: [%{card_dbf_id: 74097, turn: 3}],
        deckcode:
          "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      },
      opponent: %PlayerDto{
        battletag: nil,
        rank: nil,
        legend_rank: nil
      },
      result: "WON",
      game_id: "bla bla car",
      game_type: 7,
      format: 2
    }
    @with_unknown_card_stats %GameDto{
      player: %PlayerDto{
        battletag: "D0nkey#2470",
        rank: nil,
        legend_rank: nil,
        cards_in_hand_after_mulligan: [%{card_id: "THIS DOEST NOT EXIST", kept: false}],
        cards_drawn_from_initial_deck: [%{card_id: "CORE_CFM_753", turn: 3}],
        deckcode:
          "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      },
      opponent: %PlayerDto{
        battletag: nil,
        rank: nil,
        legend_rank: nil
      },
      result: "WON",
      game_id: "bla bla car",
      game_type: 7,
      format: 2
    }

    test "handle_game/1 returns new game and updates it" do
      assert {:ok, %Game{status: :in_progress, turns: nil, duration: nil}} =
               DeckTracker.handle_game(@valid_dto)

      update_dto = %{@valid_dto | result: "WON", turns: 7, duration: 480}
      assert {:ok, %{status: :win, turns: 7, duration: 480}} = DeckTracker.handle_game(update_dto)
    end

    test "handle_game/1 supports minimal info" do
      assert {:ok, %Game{status: :win, turns: nil, duration: nil, game_id: "bla bla car"}} =
               DeckTracker.handle_game(@minimal_dto)
    end

    test "handle_game/1 saves raw stats when card is not known" do
      assert {:ok, %Game{status: :win, turns: nil, duration: nil, game_id: "bla bla car"} = game} =
               DeckTracker.handle_game(@with_unknown_card_stats)

      preloaded = Backend.Repo.preload(game, :raw_player_card_stats)
      assert %{cards_in_hand_after_mulligan: _} = preloaded.raw_player_card_stats
    end

    test "handle_game/1 saves card_tallies when cards are known" do
      assert {:ok, %Game{status: :win, turns: nil, duration: nil, game_id: "bla bla car"} = game} =
               DeckTracker.handle_game(@with_known_card_stats)

      preloaded = Backend.Repo.preload(game, :card_tallies)
      assert %{card_tallies: [_ | _]} = preloaded
    end

    test "doesn't convert freshly inserted raw_stats" do
      assert {:ok, %Game{status: :win, turns: nil, duration: nil, game_id: "bla bla car"} = game} =
               DeckTracker.handle_game(@with_unknown_card_stats)

      assert %{cards_in_hand_after_mulligan: _} = DeckTracker.raw_stats_for_game(game)

      DeckTracker.convert_raw_stats_to_card_tallies()

      assert [] = DeckTracker.card_tallies_for_game(game)
      assert %{cards_drawn_from_initial_deck: _} = DeckTracker.raw_stats_for_game(game)
    end

    test "converts raw_stats_with_known_cards" do
      game_dto = @valid_dto |> Map.put("game_id", Ecto.UUID.generate())
      assert {:ok, %Game{id: id} = game} = DeckTracker.handle_game(game_dto)

      raw_attrs = %{
        "game_id" => id,
        "cards_drawn_from_initial_deck" => [
          %{
            "card_dbf_id" => 74097,
            "turn" => 5
          }
        ]
      }

      {:ok, %{id: raw_stats_id}} =
        %RawPlayerCardStats{}
        |> RawPlayerCardStats.changeset(raw_attrs)
        |> Repo.insert()

      assert %{cards_in_hand_after_mulligan: _} = DeckTracker.raw_stats_for_game(game)

      DeckTracker.convert_raw_stats_to_card_tallies(min_id: raw_stats_id - 1)

      assert is_nil(DeckTracker.raw_stats_for_game(game))
      assert [_ | _] = DeckTracker.card_tallies_for_game(game)
    end
  end

  alias Hearthstone.DeckTracker.Period

  @valid_attrs %{
    auto_aggregate: true,
    display: "some display",
    hours_ago: 42,
    include_in_deck_filters: true,
    include_in_personal_filters: true,
    period_end: ~N[2023-07-30 23:22:00],
    period_start: ~N[2023-07-30 23:22:00],
    slug: "some slug",
    type: "some type"
  }
  @update_attrs %{
    auto_aggregate: false,
    display: "some updated display",
    hours_ago: 43,
    include_in_deck_filters: false,
    include_in_personal_filters: false,
    period_end: ~N[2023-07-31 23:22:00],
    period_start: ~N[2023-07-31 23:22:00],
    slug: "some updated slug",
    type: "some updated type"
  }
  @invalid_attrs %{
    auto_aggregate: nil,
    display: nil,
    hours_ago: nil,
    include_in_deck_filters: nil,
    include_in_personal_filters: nil,
    period_end: nil,
    period_start: nil,
    slug: nil,
    type: nil
  }

  describe "#paginate_periods/1" do
    test "returns paginated list of periods" do
      for _ <- 1..20 do
        period_fixture()
      end

      {:ok, %{periods: periods} = page} = DeckTracker.paginate_periods(%{})

      assert length(periods) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_periods/0" do
    test "returns all periods" do
      period = period_fixture()
      assert DeckTracker.list_periods() == [period]
    end
  end

  describe "#get_period!/1" do
    test "returns the period with given id" do
      period = period_fixture()
      assert DeckTracker.get_period!(period.id) == period
    end
  end

  describe "#create_period/1" do
    test "with valid data creates a period" do
      assert {:ok, %Period{} = period} = DeckTracker.create_period(@valid_attrs)
      assert period.auto_aggregate == true
      assert period.display == "some display"
      assert period.hours_ago == 42
      assert period.include_in_deck_filters == true
      assert period.include_in_personal_filters == true
      assert period.period_end == ~N[2023-07-30 23:22:00]
      assert period.period_start == ~N[2023-07-30 23:22:00]
      assert period.slug == "some slug"
      assert period.type == "some type"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DeckTracker.create_period(@invalid_attrs)
    end
  end

  describe "#update_period/2" do
    test "with valid data updates the period" do
      period = period_fixture()
      assert {:ok, period} = DeckTracker.update_period(period, @update_attrs)
      assert %Period{} = period
      assert period.auto_aggregate == false
      assert period.display == "some updated display"
      assert period.hours_ago == 43
      assert period.include_in_deck_filters == false
      assert period.include_in_personal_filters == false
      assert period.period_end == ~N[2023-07-31 23:22:00]
      assert period.period_start == ~N[2023-07-31 23:22:00]
      assert period.slug == "some updated slug"
      assert period.type == "some updated type"
    end

    test "with invalid data returns error changeset" do
      period = period_fixture()
      assert {:error, %Ecto.Changeset{}} = DeckTracker.update_period(period, @invalid_attrs)
      assert period == DeckTracker.get_period!(period.id)
    end
  end

  describe "#delete_period/1" do
    test "deletes the period" do
      period = period_fixture()
      assert {:ok, %Period{}} = DeckTracker.delete_period(period)
      assert_raise Ecto.NoResultsError, fn -> DeckTracker.get_period!(period.id) end
    end
  end

  describe "#change_period/1" do
    test "returns a period changeset" do
      period = period_fixture()
      assert %Ecto.Changeset{} = DeckTracker.change_period(period)
    end
  end

  def period_fixture(attrs \\ %{}) do
    {:ok, period} =
      attrs
      |> Enum.into(@valid_attrs)
      |> DeckTracker.create_period()

    period
  end

  alias Hearthstone.DeckTracker.Rank

  @valid_attrs %{
    auto_aggregate: true,
    display: "some display",
    include_in_deck_filters: true,
    include_in_personal_filters: true,
    max_legend_rank: 42,
    max_rank: 42,
    min_legend_rank: 42,
    min_rank: 42,
    slug: "some slug"
  }
  @update_attrs %{
    auto_aggregate: false,
    display: "some updated display",
    include_in_deck_filters: false,
    include_in_personal_filters: false,
    max_legend_rank: 43,
    max_rank: 43,
    min_legend_rank: 43,
    min_rank: 43,
    slug: "some updated slug"
  }
  @invalid_attrs %{
    auto_aggregate: nil,
    display: nil,
    include_in_deck_filters: nil,
    include_in_personal_filters: nil,
    max_legend_rank: nil,
    max_rank: nil,
    min_legend_rank: nil,
    min_rank: nil,
    slug: nil
  }

  describe "#paginate_ranks/1" do
    test "returns paginated list of ranks" do
      for _ <- 1..20 do
        rank_fixture()
      end

      {:ok, %{ranks: ranks} = page} = DeckTracker.paginate_ranks(%{})

      assert length(ranks) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_ranks/0" do
    test "returns all ranks" do
      rank = rank_fixture()
      assert DeckTracker.list_ranks() == [rank]
    end
  end

  describe "#get_rank!/1" do
    test "returns the rank with given id" do
      rank = rank_fixture()
      assert DeckTracker.get_rank!(rank.id) == rank
    end
  end

  describe "#create_rank/1" do
    test "with valid data creates a rank" do
      assert {:ok, %Rank{} = rank} = DeckTracker.create_rank(@valid_attrs)
      assert rank.auto_aggregate == true
      assert rank.display == "some display"
      assert rank.include_in_deck_filters == true
      assert rank.include_in_personal_filters == true
      assert rank.max_legend_rank == 42
      assert rank.max_rank == 42
      assert rank.min_legend_rank == 42
      assert rank.min_rank == 42
      assert rank.slug == "some slug"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DeckTracker.create_rank(@invalid_attrs)
    end
  end

  describe "#update_rank/2" do
    test "with valid data updates the rank" do
      rank = rank_fixture()
      assert {:ok, rank} = DeckTracker.update_rank(rank, @update_attrs)
      assert %Rank{} = rank
      assert rank.auto_aggregate == false
      assert rank.display == "some updated display"
      assert rank.include_in_deck_filters == false
      assert rank.include_in_personal_filters == false
      assert rank.max_legend_rank == 43
      assert rank.max_rank == 43
      assert rank.min_legend_rank == 43
      assert rank.min_rank == 43
      assert rank.slug == "some updated slug"
    end

    test "with invalid data returns error changeset" do
      rank = rank_fixture()
      assert {:error, %Ecto.Changeset{}} = DeckTracker.update_rank(rank, @invalid_attrs)
      assert rank == DeckTracker.get_rank!(rank.id)
    end
  end

  describe "#delete_rank/1" do
    test "deletes the rank" do
      rank = rank_fixture()
      assert {:ok, %Rank{}} = DeckTracker.delete_rank(rank)
      assert_raise Ecto.NoResultsError, fn -> DeckTracker.get_rank!(rank.id) end
    end
  end

  describe "#change_rank/1" do
    test "returns a rank changeset" do
      rank = rank_fixture()
      assert %Ecto.Changeset{} = DeckTracker.change_rank(rank)
    end
  end

  def rank_fixture(attrs \\ %{}) do
    {:ok, rank} =
      attrs
      |> Enum.into(@valid_attrs)
      |> DeckTracker.create_rank()

    rank
  end

  alias Hearthstone.DeckTracker.Format

  @valid_attrs %{
    auto_aggregate: true,
    default: true,
    display: "some display",
    include_in_deck_filters: true,
    include_in_personal_filters: true,
    order_priority: 42,
    value: 42
  }
  @update_attrs %{
    auto_aggregate: false,
    default: false,
    display: "some updated display",
    include_in_deck_filters: false,
    include_in_personal_filters: false,
    order_priority: 43,
    value: 43
  }
  @invalid_attrs %{
    auto_aggregate: nil,
    default: nil,
    display: nil,
    include_in_deck_filters: nil,
    include_in_personal_filters: nil,
    order_priority: nil,
    value: nil
  }

  describe "#paginate_formats/1" do
    test "returns paginated list of formats" do
      for _ <- 1..20 do
        format_fixture()
      end

      {:ok, %{formats: formats} = page} = DeckTracker.paginate_formats(%{})

      assert length(formats) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_formats/0" do
    test "returns all formats" do
      format = format_fixture()
      assert DeckTracker.list_formats() == [format]
    end
  end

  describe "#get_format!/1" do
    test "returns the format with given id" do
      format = format_fixture()
      assert DeckTracker.get_format!(format.id) == format
    end
  end

  describe "#create_format/1" do
    test "with valid data creates a format" do
      assert {:ok, %Format{} = format} = DeckTracker.create_format(@valid_attrs)
      assert format.auto_aggregate == true
      assert format.default == true
      assert format.display == "some display"
      assert format.include_in_deck_filters == true
      assert format.include_in_personal_filters == true
      assert format.order_priority == 42
      assert format.value == 42
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DeckTracker.create_format(@invalid_attrs)
    end
  end

  describe "#update_format/2" do
    test "with valid data updates the format" do
      format = format_fixture()
      assert {:ok, format} = DeckTracker.update_format(format, @update_attrs)
      assert %Format{} = format
      assert format.auto_aggregate == false
      assert format.default == false
      assert format.display == "some updated display"
      assert format.include_in_deck_filters == false
      assert format.include_in_personal_filters == false
      assert format.order_priority == 43
      assert format.value == 43
    end

    test "with invalid data returns error changeset" do
      format = format_fixture()
      assert {:error, %Ecto.Changeset{}} = DeckTracker.update_format(format, @invalid_attrs)
      assert format == DeckTracker.get_format!(format.id)
    end
  end

  describe "#delete_format/1" do
    test "deletes the format" do
      format = format_fixture()
      assert {:ok, %Format{}} = DeckTracker.delete_format(format)
      assert_raise Ecto.NoResultsError, fn -> DeckTracker.get_format!(format.id) end
    end
  end

  describe "#change_format/1" do
    test "returns a format changeset" do
      format = format_fixture()
      assert %Ecto.Changeset{} = DeckTracker.change_format(format)
    end
  end

  def format_fixture(attrs \\ %{}) do
    {:ok, format} =
      attrs
      |> Enum.into(@valid_attrs)
      |> DeckTracker.create_format()

    format
  end
end
