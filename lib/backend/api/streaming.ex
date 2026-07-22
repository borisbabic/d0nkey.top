defmodule Backend.Api.Streaming do
  @moduledoc "Query, validation, and serialization for the developer streaming API."

  alias Backend.Hearthstone.Deck
  alias Backend.Streaming, as: StreamingContext
  alias Backend.Streaming.Streamer
  alias Backend.Streaming.StreamerDeck
  alias Backend.Streaming.StreamingNow
  alias Hearthstone.Enums.BnetGameType
  alias Hearthstone.Enums.Format

  @streamer_params ~w(limit offset search sort_by sort_direction twitch_login)
  @streamer_deck_params ~w(
    best_legend_rank class deck_id exclude_cards first_played_within_minutes format
    include_cards last_played_within_minutes latest_legend_rank limit min_minutes_played
    offset sort_by sort_direction twitch_id twitch_login worst_legend_rank
  )
  @live_stream_params ~w(deckcode has_deck language legend_rank limit mode sort_by)

  @streamer_sort_fields %{
    "created_at" => :inserted_at,
    "display_name" => :display_name,
    "login" => :login
  }
  @streamer_deck_sort_fields %{
    "best_legend_rank" => :best_legend_rank,
    "first_played" => :first_played,
    "last_played" => :last_played,
    "latest_legend_rank" => :latest_legend_rank,
    "losses" => :losses,
    "minutes_played" => :minutes_played,
    "wins" => :wins,
    "worst_legend_rank" => :worst_legend_rank
  }
  @sort_directions ~w(asc desc)
  @live_sort_fields ~w(fewest_viewers most_viewers newest oldest)
  @has_deck_values ~w(any yes no)
  @format_values %{
    "1" => 1,
    "wild" => 1,
    "2" => 2,
    "standard" => 2,
    "3" => 3,
    "classic" => 3,
    "4" => 4,
    "twist" => 4
  }
  @default_limit 50
  @maximum_limit 100
  @maximum_offset 100_000
  @maximum_list_size 25
  @maximum_integer 2_147_483_647

  @spec streamers(map()) :: {:ok, map()} | {:error, term()}
  def streamers(params) do
    with :ok <- reject_unknown_params(params, @streamer_params),
         {:ok, limit} <- integer_param(params, "limit", @default_limit, 1, @maximum_limit),
         {:ok, offset} <- integer_param(params, "offset", 0, 0, @maximum_offset),
         {:ok, search} <- optional_text_param(params, "search", 100),
         {:ok, twitch_logins} <- string_list_param(params, "twitch_login"),
         {:ok, sort_by} <- mapped_enum_param(params, "sort_by", "display_name", @streamer_sort_fields),
         {:ok, sort_direction} <- enum_param(params, "sort_direction", "asc", @sort_directions) do
      query_params =
        %{
          "limit" => limit + 1,
          "offset" => offset,
          "order_by" => {direction_atom(sort_direction), sort_by}
        }
        |> put_optional("search", search)
        |> put_optional("twitch_login", twitch_logins)

      results = StreamingContext.streamers_with_stats(query_params)
      has_more = length(results) > limit

      {:ok,
       %{
         filters: %{
           limit: limit,
           offset: offset,
           search: search,
           sort_by: map_key_for_value(@streamer_sort_fields, sort_by),
           sort_direction: sort_direction,
           twitch_login: twitch_logins
         },
         streamers: results |> Enum.take(limit) |> Enum.map(&serialize_streamer_summary/1),
         pagination: offset_pagination(limit, offset, has_more)
       }}
    end
  end

  @spec streamer_decks(map()) :: {:ok, map()} | {:error, term()}
  def streamer_decks(params) do
    with :ok <- reject_unknown_params(params, @streamer_deck_params),
         {:ok, limit} <- integer_param(params, "limit", @default_limit, 1, @maximum_limit),
         {:ok, offset} <- integer_param(params, "offset", 0, 0, @maximum_offset),
         {:ok, format} <- optional_format_param(params),
         {:ok, player_class} <- optional_class_param(params),
         {:ok, twitch_logins} <- string_list_param(params, "twitch_login"),
         {:ok, twitch_ids} <- positive_integer_list_param(params, "twitch_id"),
         {:ok, include_cards} <- positive_integer_list_param(params, "include_cards"),
         {:ok, exclude_cards} <- positive_integer_list_param(params, "exclude_cards"),
         {:ok, deck_id} <- optional_positive_integer_param(params, "deck_id"),
         {:ok, best_legend_rank} <- optional_positive_integer_param(params, "best_legend_rank"),
         {:ok, latest_legend_rank} <- optional_positive_integer_param(params, "latest_legend_rank"),
         {:ok, worst_legend_rank} <- optional_positive_integer_param(params, "worst_legend_rank"),
         {:ok, min_minutes_played} <- optional_non_negative_integer_param(params, "min_minutes_played"),
         {:ok, last_played_minutes} <-
           optional_positive_integer_param(params, "last_played_within_minutes"),
         {:ok, first_played_minutes} <-
           optional_positive_integer_param(params, "first_played_within_minutes"),
         {:ok, sort_by} <-
           mapped_enum_param(params, "sort_by", "last_played", @streamer_deck_sort_fields),
         {:ok, sort_direction} <- enum_param(params, "sort_direction", "desc", @sort_directions) do
      query_params =
        %{
          "limit" => limit + 1,
          "offset" => offset,
          "order_by" => {direction_atom(sort_direction), sort_by}
        }
        |> put_optional("format", format)
        |> put_optional("class", player_class)
        |> put_optional("twitch_login", twitch_logins)
        |> put_optional("twitch_id", twitch_ids)
        |> put_optional("include_cards", include_cards)
        |> put_optional("exclude_cards", exclude_cards)
        |> put_optional("deck_id", deck_id)
        |> put_optional("best_legend_rank", best_legend_rank)
        |> put_optional("latest_legend_rank", latest_legend_rank)
        |> put_optional("worst_legend_rank", worst_legend_rank)
        |> put_optional("min_minutes_played", min_minutes_played)
        |> put_minutes_filter("last_played", last_played_minutes)
        |> put_minutes_filter("first_played", first_played_minutes)

      results = StreamingContext.streamer_decks(query_params)
      has_more = length(results) > limit

      filters =
        params
        |> Map.put("limit", limit)
        |> Map.put("offset", offset)
        |> Map.put("sort_by", map_key_for_value(@streamer_deck_sort_fields, sort_by))
        |> Map.put("sort_direction", sort_direction)

      {:ok,
       %{
         filters: filters,
         streamer_decks: results |> Enum.take(limit) |> Enum.map(&serialize_streamer_deck/1),
         pagination: offset_pagination(limit, offset, has_more)
       }}
    end
  end

  @spec live_streams(map(), list()) :: {:ok, map()} | {:error, term()}
  def live_streams(params, streams \\ StreamingNow.streaming_now()) do
    with :ok <- reject_unknown_params(params, @live_stream_params),
         {:ok, limit} <- integer_param(params, "limit", @default_limit, 1, @maximum_limit),
         {:ok, mode} <- optional_text_param(params, "mode", 50),
         {:ok, language} <- optional_text_param(params, "language", 20),
         {:ok, deckcode} <- optional_text_param(params, "deckcode", 1000),
         {:ok, legend_rank} <- optional_positive_integer_param(params, "legend_rank"),
         {:ok, has_deck} <- enum_param(params, "has_deck", "any", @has_deck_values),
         {:ok, sort_by} <- enum_param(params, "sort_by", "most_viewers", @live_sort_fields) do
      filtered =
        streams
        |> Enum.filter(&matches_live_stream?(&1, mode, language, deckcode, legend_rank, has_deck))
        |> sort_live_streams(sort_by)

      {:ok,
       %{
         filters: %{
           deckcode: deckcode,
           has_deck: has_deck,
           language: language,
           legend_rank: legend_rank,
           limit: limit,
           mode: mode,
           sort_by: sort_by
         },
         streams: filtered |> Enum.take(limit) |> Enum.map(&serialize_live_stream/1),
         total: length(filtered)
       }}
    end
  end

  defp reject_unknown_params(params, allowed) do
    case Map.keys(params) -- allowed do
      [] -> :ok
      [parameter | _] -> invalid_parameter(parameter, "is not supported")
    end
  end

  defp integer_param(params, key, default, minimum, maximum) do
    value = Map.get(params, key, default)

    with {:ok, integer} <- parse_integer(value),
         true <- integer >= minimum and integer <= maximum do
      {:ok, integer}
    else
      _ -> invalid_parameter(key, "must be an integer between #{minimum} and #{maximum}")
    end
  end

  defp optional_positive_integer_param(params, key),
    do: optional_integer_param(params, key, 1)

  defp optional_non_negative_integer_param(params, key),
    do: optional_integer_param(params, key, 0)

  defp optional_integer_param(params, key, minimum) do
    case Map.get(params, key) do
      nil -> {:ok, nil}
      value -> parse_optional_integer(key, value, minimum)
    end
  end

  defp parse_optional_integer(key, value, minimum) do
    with {:ok, integer} <- parse_integer(value),
         true <- integer >= minimum and integer <= @maximum_integer do
      {:ok, integer}
    else
      _ -> invalid_parameter(key, "must be an integer between #{minimum} and #{@maximum_integer}")
    end
  end

  defp parse_integer(value) when is_integer(value), do: {:ok, value}

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> {:ok, integer}
      _ -> :error
    end
  end

  defp parse_integer(_), do: :error

  defp optional_format_param(params) do
    case Map.get(params, "format") do
      nil -> {:ok, nil}
      value -> normalize_format(value)
    end
  end

  defp normalize_format(value) when is_integer(value) and value in [1, 2, 3, 4], do: {:ok, value}

  defp normalize_format(value) when is_binary(value) do
    case Map.fetch(@format_values, String.downcase(value)) do
      {:ok, format} -> {:ok, format}
      :error -> invalid_parameter("format", "must be Wild, Standard, Classic, or Twist")
    end
  end

  defp normalize_format(_),
    do: invalid_parameter("format", "must be Wild, Standard, Classic, or Twist")

  defp optional_class_param(params) do
    case Map.get(params, "class") do
      nil ->
        {:ok, nil}

      value when is_binary(value) ->
        normalized = String.upcase(value)

        if normalized in Deck.classes(),
          do: {:ok, normalized},
          else: invalid_parameter("class", "must be a valid Hearthstone class")

      _ ->
        invalid_parameter("class", "must be a valid Hearthstone class")
    end
  end

  defp optional_text_param(params, key, maximum_length) do
    case Map.get(params, key) do
      nil ->
        {:ok, nil}

      value when is_binary(value) ->
        trimmed = String.trim(value)

        if trimmed != "" and String.length(trimmed) <= maximum_length,
          do: {:ok, trimmed},
          else: invalid_parameter(key, "must be a non-empty string up to #{maximum_length} characters")

      _ ->
        invalid_parameter(key, "must be a non-empty string up to #{maximum_length} characters")
    end
  end

  defp string_list_param(params, key) do
    case Map.get(params, key) do
      nil ->
        {:ok, nil}

      value ->
        values = List.wrap(value)

        if length(values) in 1..@maximum_list_size and
             Enum.all?(values, &(is_binary(&1) and String.trim(&1) != "" and String.length(&1) <= 100)) do
          normalized = values |> Enum.map(&(String.trim(&1) |> String.downcase())) |> Enum.uniq()
          {:ok, normalized}
        else
          invalid_parameter(key, "must contain 1 to #{@maximum_list_size} non-empty values")
        end
    end
  end

  defp positive_integer_list_param(params, key) do
    case Map.get(params, key) do
      nil ->
        {:ok, nil}

      value ->
        values = List.wrap(value)
        parsed = Enum.map(values, &parse_integer/1)
        normalized = for {:ok, integer} <- parsed, uniq: true, do: integer

        if length(values) in 1..@maximum_list_size and
             Enum.all?(parsed, &valid_positive_integer?/1) do
          {:ok, normalized}
        else
          invalid_parameter(key, "must contain 1 to #{@maximum_list_size} positive integers")
        end
    end
  end

  defp mapped_enum_param(params, key, default, values) do
    raw = Map.get(params, key, default)

    case Map.fetch(values, raw) do
      {:ok, value} -> {:ok, value}
      :error -> invalid_parameter(key, "must be one of: #{values |> Map.keys() |> Enum.sort() |> Enum.join(", ")}")
    end
  end

  defp valid_positive_integer?({:ok, integer}), do: integer in 1..@maximum_integer
  defp valid_positive_integer?(_), do: false

  defp enum_param(params, key, default, values) do
    value = Map.get(params, key, default)

    if value in values,
      do: {:ok, value},
      else: invalid_parameter(key, "must be one of: #{Enum.join(values, ", ")}")
  end

  defp direction_atom("asc"), do: :asc
  defp direction_atom(_), do: :desc

  defp map_key_for_value(map, value) do
    Enum.find_value(map, fn {key, mapped_value} -> if mapped_value == value, do: key end)
  end

  defp put_optional(map, _key, nil), do: map
  defp put_optional(map, _key, []), do: map
  defp put_optional(map, key, value), do: Map.put(map, key, value)

  defp put_minutes_filter(map, _key, nil), do: map
  defp put_minutes_filter(map, key, minutes), do: Map.put(map, key, "min_ago_#{minutes}")

  defp offset_pagination(limit, offset, has_more) do
    %{
      limit: limit,
      offset: offset,
      next_offset: if(has_more, do: offset + limit, else: nil)
    }
  end

  defp serialize_streamer(streamer) do
    login = Streamer.twitch_login(streamer)

    %{
      twitch_id: to_string(streamer.twitch_id),
      login: login,
      display_name: Streamer.twitch_display(streamer),
      twitch_url: twitch_url(login)
    }
  end

  defp serialize_streamer_summary(%{streamer: streamer} = summary) do
    recorded_games = summary.wins + summary.losses

    streamer
    |> serialize_streamer()
    |> Map.put(:stats, %{
      deck_count: summary.deck_count,
      recorded_games: recorded_games,
      wins: summary.wins,
      losses: summary.losses,
      winrate: safe_div(summary.wins, recorded_games),
      minutes_played: summary.minutes_played,
      best_legend_rank: summary.best_legend_rank,
      last_played: iso8601(summary.last_played)
    })
  end

  defp serialize_streamer_deck(%StreamerDeck{} = streamer_deck) do
    %{
      streamer: serialize_streamer(streamer_deck.streamer),
      deck: serialize_deck(streamer_deck.deck),
      first_played: iso8601(streamer_deck.first_played),
      last_played: iso8601(streamer_deck.last_played),
      mode: %{
        game_type: streamer_deck.game_type,
        name: BnetGameType.game_type_name(streamer_deck.game_type)
      },
      ranks: %{
        best: zero_to_nil(streamer_deck.best_rank),
        best_legend: zero_to_nil(streamer_deck.best_legend_rank),
        latest_legend: zero_to_nil(streamer_deck.latest_legend_rank),
        worst_legend: zero_to_nil(streamer_deck.worst_legend_rank)
      },
      performance: %{
        minutes_played: streamer_deck.minutes_played,
        wins: streamer_deck.wins,
        losses: streamer_deck.losses,
        winrate: StreamerDeck.winrate(streamer_deck)
      }
    }
  end

  defp serialize_deck(deck) do
    archetype = Deck.archetype(deck)

    %{
      id: deck.id,
      deckcode: deck.deckcode,
      format: %{id: deck.format, name: Format.name(deck.format)},
      class: Deck.class(deck),
      archetype: archetype && to_string(archetype),
      dust_cost: deck.cost,
      cards: serialize_cards(deck.cards),
      sideboards: serialize_sideboards(deck.sideboards),
      url: Deck.link(deck)
    }
  end

  defp serialize_cards(cards) do
    cards
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {dbf_id, count} -> %{dbf_id: dbf_id, count: count} end)
  end

  defp serialize_sideboards(sideboards) do
    Enum.map(List.wrap(sideboards), fn sideboard ->
      %{dbf_id: sideboard.card, count: sideboard.count, owner_dbf_id: sideboard.sideboard}
    end)
  end

  defp matches_live_stream?(stream, mode, language, deckcode, legend_rank, has_deck) do
    matches_mode?(stream, mode) and
      matches_language?(stream, language) and
      matches_deckcode?(stream, deckcode) and
      matches_legend_rank?(stream, legend_rank) and
      matches_has_deck?(stream, has_deck)
  end

  defp matches_mode?(_stream, nil), do: true

  defp matches_mode?(stream, mode) do
    stream.game_type
    |> BnetGameType.game_type_name()
    |> String.downcase()
    |> Kernel.==(String.downcase(mode))
  end

  defp matches_language?(_stream, nil), do: true

  defp matches_language?(stream, language),
    do: String.downcase(stream.language || "") == String.downcase(language)

  defp matches_deckcode?(_stream, nil), do: true
  defp matches_deckcode?(stream, deckcode), do: stream.deckcode == deckcode

  defp matches_legend_rank?(_stream, nil), do: true

  defp matches_legend_rank?(%{legend_rank: rank}, maximum_rank),
    do: is_integer(rank) and rank > 0 and rank <= maximum_rank

  defp matches_has_deck?(_stream, "any"), do: true
  defp matches_has_deck?(%{deckcode: deckcode}, "yes"), do: is_binary(deckcode) and deckcode != ""
  defp matches_has_deck?(%{deckcode: deckcode}, "no"), do: is_nil(deckcode) or deckcode == ""

  defp sort_live_streams(streams, "newest"),
    do: Enum.sort_by(streams, &datetime_sort_value(&1.started_at), :desc)

  defp sort_live_streams(streams, "oldest"),
    do: Enum.sort_by(streams, &datetime_sort_value(&1.started_at), :asc)

  defp sort_live_streams(streams, "fewest_viewers"),
    do: Enum.sort_by(streams, &(&1.viewer_count || 0), :asc)

  defp sort_live_streams(streams, _),
    do: Enum.sort_by(streams, &(&1.viewer_count || 0), :desc)

  defp serialize_live_stream(stream) do
    %{
      twitch_id: to_string(stream.user_id),
      display_name: stream.user_name,
      twitch_url: twitch_url(stream.user_name),
      stream_id: to_string(stream.stream_id),
      title: stream.title,
      language: stream.language,
      viewer_count: stream.viewer_count,
      started_at: iso8601(stream.started_at),
      legend_rank: stream.legend_rank,
      deckcode: stream.deckcode,
      game_type: stream.game_type,
      mode: BnetGameType.game_type_name(stream.game_type)
    }
  end

  defp datetime_sort_value(%DateTime{} = datetime), do: DateTime.to_unix(datetime, :microsecond)

  defp datetime_sort_value(%NaiveDateTime{} = datetime),
    do: NaiveDateTime.diff(datetime, ~N[1970-01-01 00:00:00], :microsecond)

  defp datetime_sort_value(_), do: 0

  defp iso8601(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)
  defp iso8601(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_iso8601(datetime)
  defp iso8601(_), do: nil

  defp twitch_url(login) when is_binary(login) and login != "",
    do: "https://www.twitch.tv/#{URI.encode(login)}"

  defp twitch_url(_), do: nil

  defp zero_to_nil(value) when value in [nil, 0], do: nil
  defp zero_to_nil(value), do: value

  defp safe_div(_, 0), do: nil
  defp safe_div(value, total), do: value / total

  defp invalid_parameter(parameter, message),
    do: {:error, {:invalid_parameter, parameter, message}}
end
