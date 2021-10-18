defmodule Backend.Infrastructure.BattlefyCommunicator do
  @moduledoc false
  require Logger
  alias Backend.Battlefy
  alias Backend.Blizzard
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchDeckstrings
  alias Backend.Battlefy.Profile
  alias Backend.Battlefy.Team
  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Organization
  import Backend.Battlefy.Communicator
  @behaviour Backend.Battlefy.Communicator
  @type signup_options :: Communicator.signup_options()
  @type qualifier :: Communicator.qualifier()

  use Tesla
  plug Tesla.Middleware.Cache, ttl: :timer.seconds(30)

  def get_body(url) do
    response = get_response(url)
    response.body
  end

  def get_response(url) do
    {u_secs, response} = :timer.tc(&get!/1, [url |> encode()])
    Logger.debug("Got #{url} in #{div(u_secs, 1000)} ms")
    response
  end

  def encode(url) do
    url
    |> URI.encode()
    |> String.replace("[", "%5B")
    |> String.replace("]", "%5D")
  end

  @doc """
  Get's the qualifiers that start between the start and end date (inclusive)
  """
  @spec get_masters_qualifiers(Date.t(), Date.t()) :: [qualifier]
  def get_masters_qualifiers(start_date = %Date{}, end_date = %Date{}) do
    get_masters_qualifiers(Util.day_start(start_date, :naive), Util.day_end(end_date, :naive))
  end

  @doc """
  Get's the qualifiers that start between the start and end_time
  """
  @spec get_masters_qualifiers(NaiveDateTime.t(), NaiveDateTime.t()) :: [qualifier]
  def get_masters_qualifiers(start_time = %NaiveDateTime{}, end_time = %NaiveDateTime{}) do
    url =
      "https://majestic.battlefy.com/hearthstone-masters/tournaments?start=#{
        NaiveDateTime.to_iso8601(start_time)
      }&end=#{NaiveDateTime.to_iso8601(end_time)}"

    {u_secs, response} = :timer.tc(&HTTPoison.get!/1, [url])
    Logger.debug("Got masters qualifiers #{url} in #{div(u_secs, 1000)} ms")

    Jason.decode!(response.body)
    |> Enum.map(fn %{
                     "startTime" => start_time,
                     "name" => name,
                     "slug" => slug,
                     "region" => region,
                     "_id" => id
                   } ->
      %{
        start_time: elem(NaiveDateTime.from_iso8601(start_time), 1),
        name: name,
        region: region,
        id: id,
        slug: slug
      }
    end)
  end

  @spec get_invited_players(Blizzard.tour_stop() | String.t() | nil) :: Battlefy.invited_player()
  def get_invited_players(tour_stop \\ nil) do
    url =
      case tour_stop do
        nil -> "https://majestic.battlefy.com/hearthstone-masters/invitees"
        ts -> "https://majestic.battlefy.com/hearthstone-masters/invitees?tourStop=#{ts}"
      end

    {u_secs, response} = :timer.tc(&HTTPoison.get!/1, [URI.encode(url)])

    Logger.debug(
      "Got invited players #{tour_stop && "for #{tour_stop} "}in #{div(u_secs, 1000)} ms"
    )

    Jason.decode!(response.body)
    |> Enum.map(
      fn invited = %{
           "battletag" => battletag_full,
           "type" => type,
           "tourStop" => tour_stop,
           "createdAt" => upstream_time
         } ->
        %{
          battletag_full: String.trim(battletag_full),
          reason: invited["reason"] || type,
          type: type,
          tour_stop: tour_stop,
          upstream_time: elem(NaiveDateTime.from_iso8601(upstream_time), 1),
          tournament_slug: invited["tournamentSlug"],
          official: true,
          tournament_id: invited["tournamentID"]
        }
      end
    )
  end

  @spec get_stage_with_matches(Backend.Battlefy.stage_id()) :: Backend.Battlefy.Stage.t()
  def get_stage_with_matches(stage_id) do
    url =
      "https://dtmwra1jsgyb0.cloudfront.net/stages/#{stage_id}?extend[matches][top.team][players][user]=true&extend[matches][top.team][persistentTeam]=true&extend[matches][bottom.team][players][user]=true&extend[matches][bottom.team][persistentTeam]=true&extend[groups][teams]=true&extend[groups][matches][top.team][players][user]=true&extend[groups][matches][top.team][persistentTeam]=true&extend[groups][matches][bottom.team][players][user]=true&extend[groups][matches][bottom.team][persistentTeam]=true"

    get_body(url)
    |> Jason.decode!()
    |> case do
      [r] -> r
      r -> raise("WTF #{r |> Enum.count()}")
    end
    |> Backend.Battlefy.Stage.from_raw_map()
  end

  @spec get_stage(Backend.Battlefy.stage_id()) :: Backend.Battlefy.Stage.t()
  def get_stage(stage_id) do
    url = "https://dtmwra1jsgyb0.cloudfront.net/stages/#{stage_id}"

    get_body(url)
    |> Jason.decode!()
    |> Backend.Battlefy.Stage.from_raw_map()
  end

  @spec get_standings(Backend.Battlefy.stage_id()) :: [Backend.Battlefy.Standings.t()]
  def get_standings(stage_id) do
    url = "https://dtmwra1jsgyb0.cloudfront.net/stages/#{stage_id}/standings"

    get_body(url)
    |> Jason.decode!()
    |> Backend.Battlefy.Standings.from_raw_map_list()
  end

  @spec get_round_standings(Backend.Battlefy.stage_id(), integer | String.t()) :: [
          Backend.Battlefy.Standings.t()
        ]
  def get_round_standings(stage_id, round) do
    url = "https://dtmwra1jsgyb0.cloudfront.net/stages/#{stage_id}/rounds/#{round}/standings"

    get_body(url)
    |> Jason.decode!()
    |> Backend.Battlefy.Standings.from_raw_map_list()
  end

  @spec get_tournament(Backend.Battlefy.tournament_id()) :: Backend.Battlefy.Tournament.t()
  def get_tournament(tournament_id) do
    url =
      "https://dtmwra1jsgyb0.cloudfront.net/tournaments/#{tournament_id}?extend[stages]=true&extend[organization]=true"

    get_body(url)
    |> Jason.decode!()
    |> Enum.at(0)
    |> Backend.Battlefy.Tournament.from_raw_map()
  end

  @spec get_matches(Battlefy.stage_id(), Battlefy.get_matches_options()) :: [Match.t()]
  def get_matches(stage_id, opts \\ []) do
    url =
      case opts[:round] do
        nil ->
          "https://dtmwra1jsgyb0.cloudfront.net/stages/#{stage_id}/matches"

        round ->
          "https://dtmwra1jsgyb0.cloudfront.net/stages/#{stage_id}/matches?roundNumber=#{round}"
      end

    get_body(url)
    |> Jason.decode!()
    |> Util.async_map(&Match.from_raw_map/1)
  end

  @spec get_matches(Battlefy.stage_id(), Battlefy.get_matches_options()) :: [Match.t()]
  def get_matches_raw(stage_id, opts \\ []) do
    url =
      case opts[:round] do
        nil ->
          "https://dtmwra1jsgyb0.cloudfront.net/stages/#{stage_id}/matches"

        round ->
          "https://dtmwra1jsgyb0.cloudfront.net/stages/#{stage_id}/matches?roundNumber=#{round}"
      end

    response = get_response(url)
    response.body
  end

  @spec get_match!(Battlefy.match_id()) :: Battlefy.Match.t()
  def get_match!(match_id), do: match_id |> get_match() |> Util.bangify()

  @spec get_match(Battlefy.match_id()) :: {:ok, Battlefy.Match.t()} | {:error, any()}
  def get_match(match_id) do
    url =
      "https://dtmwra1jsgyb0.cloudfront.net/matches/#{match_id}?extend[top.team][players][user]=true&extend[top.team][persistentTeam]=true&extend[bottom.team][players][user]=true&extend[bottom.team][persistentTeam]=true&extend[stats]=true"

    with body <- get_body(url),
         {:ok, decoded} <- Poison.decode(body),
         match <- Match.from_raw_map(decoded) do
      {:ok, match}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "could not fetch match"}
    end
  end

  @spec get_match_deckstrings(Battlefy.tournament_id(), Battlefy.match_id()) :: [
          MatchDeckstrings.t()
        ]
  def get_match_deckstrings(tournament_id, match_id) do
    url =
      "https://majestic.battlefy.com/tournaments/#{tournament_id}/matches/#{match_id}/deckstrings"

    get_body(url)
    |> Jason.decode!()
    |> MatchDeckstrings.from_raw_map()
  end

  def get_profile(slug) do
    url = "https://dtmwra1jsgyb0.cloudfront.net/profile/#{slug}"

    get_body(url)
    |> Jason.decode!()
    |> Profile.from_raw_map()
  end

  @spec get_organization(String.t()) :: Organization.t()
  def get_organization(slug) do
    url = "https://dtmwra1jsgyb0.cloudfront.net/organizations?slug=#{slug}"

    get_body(url)
    |> Jason.decode!()
    |> Enum.map(&Organization.from_raw_map/1)
    # dunno when we'll get more or this won't equal, but just in case :shrug:
    |> Enum.filter(fn o -> o.slug == slug end)
    |> Enum.at(0)
  end

  def get_organization_tournaments_from_to(
        slug,
        from_date = %Date{},
        to_date = %Date{}
      ) do
    get_organization_tournaments_from_to(
      slug,
      from_date |> Util.day_start(:naive),
      to_date |> Util.day_end(:naive)
    )
  end

  @spec get_organization_tournaments_from_to(
          Battlefy.organization_id(),
          NaiveDateTime.t(),
          NaiveDateTime.t()
        ) :: [Tournament.t()]
  def get_organization_tournaments_from_to(
        org_id,
        from_time = %NaiveDateTime{},
        to_time = %NaiveDateTime{}
      ) do
    now = NaiveDateTime.utc_now()

    past =
      case NaiveDateTime.compare(now, from_time) do
        :lt -> []
        _ -> get_past_organization_tournaments_from(org_id, from_time)
      end

    future =
      case NaiveDateTime.compare(now, to_time) do
        :gt -> []
        _ -> get_upcoming_organization_tournaments_to(org_id, to_time)
      end

    (past ++ future)
    |> Enum.sort_by(fn t -> t.start_time |> NaiveDateTime.to_string() end, :asc)
    |> Enum.filter(fn t ->
      NaiveDateTime.compare(t.start_time, from_time) != :lt &&
        NaiveDateTime.compare(t.start_time, to_time) != :gt
    end)
  end

  @spec get_past_organization_tournaments_from(Battlefy.organization_id(), NaiveDateTime.t()) :: [
          Tournament.t()
        ]
  def get_past_organization_tournaments_from(
        org_id,
        from_time = %NaiveDateTime{},
        page \\ 1,
        carry \\ []
      ) do
    ret = get_organization_tournaments(org_id, :past, page) || []

    ret
    |> Enum.filter(fn t -> NaiveDateTime.compare(from_time, t.start_time) != :gt end)
    |> case do
      [] ->
        carry

      new when length(new) == length(ret) ->
        get_past_organization_tournaments_from(org_id, from_time, page + 1, carry ++ new)

      new ->
        carry ++ new
    end
  end

  @spec get_upcoming_organization_tournaments_to(Battlefy.organization_id(), NaiveDateTime.t()) ::
          [Tournament.t()]
  def get_upcoming_organization_tournaments_to(
        org_id,
        to_time = %NaiveDateTime{},
        page \\ 1,
        carry \\ []
      ) do
    ret = get_organization_tournaments(org_id, :upcoming, page)

    ret
    |> Enum.filter(fn t -> NaiveDateTime.compare(to_time, t.start_time) != :lt end)
    |> case do
      [] ->
        carry

      new when length(new) == length(ret) ->
        get_upcoming_organization_tournaments_to(org_id, to_time, page + 1, carry ++ new)

      new ->
        carry ++ new
    end
  end

  @spec get_organization_tournaments(Battlefy.organization_id(), :past | :upcoming) :: [
          Tournament.t()
        ]
  def get_organization_tournaments(org_id, period, page \\ 1, size \\ 25) do
    # they return max 25 regardless of size. I don't feel like paginating or being smart about it
    url =
      "https://search.battlefy.com/tournament/organization/#{org_id}/#{period}?page=#{page}&size=#{
        size
      }"

    raw =
      get_body(url)
      |> Jason.decode!()

    raw["tournaments"]
    |> Enum.map(&Tournament.from_raw_map/1)
  end

  @spec get_user_tournaments_from(String.t(), NaiveDateTime.t()) :: [Tournament.t()]
  def get_user_tournaments_from(slug, from_time = %NaiveDateTime{}, page \\ 1, carry \\ [])
      when is_integer(page) do
    ret = get_user_tournaments(slug, page) || []

    ret
    |> Enum.filter(fn t -> NaiveDateTime.compare(from_time, t.start_time) != :gt end)
    |> case do
      [] ->
        carry

      new when length(new) == length(ret) ->
        get_user_tournaments_from(slug, from_time, page + 1, carry ++ new)

      new ->
        carry ++ new
    end
  end

  @spec get_user_tournaments(String.t()) :: [Tournament.t()]
  def get_user_tournaments(slug, page \\ 1, size \\ 25) do
    # they return max 25 regardless of size. I don't feel like paginating or being smart about it
    url = "https://search.battlefy.com/user/#{slug}/tournaments?page=#{page}&size=#{size}"

    raw =
      get_body(url)
      |> Jason.decode!()

    (raw["tournaments"] || [])
    |> Enum.map(&Tournament.from_raw_map/1)
  end

  @spec signup_for_qualifier(signup_options) :: {:ok, any} | {:error, any}
  def signup_for_qualifier(options) do
    prev_errors =
      [
        &accept_rules/1,
        &connect_battlenet/1,
        &masters_eligibility/1,
        &submit_discord/1,
        &submit_decks/1
      ]
      |> Enum.reduce([], fn f, carry ->
        options
        |> f.()
        |> case do
          {:ok, _} -> carry
          {:error, reason} -> [reason | carry]
        end
      end)

    case join_tournament(options) do
      {:error, reason} ->
        {:error, [reason | prev_errors]}

      {:ok, _} ->
        Logger.debug(
          "Successfully signed up #{options.battletag_full} fo #{options.tournament_id}"
        )

        {:ok, nil}
    end
  end

  @spec put_form_fields(signup_options, String.t()) :: {:ok, any} | {:error, any}
  def put_form_fields(options = %{token: token}, body) do
    url = form_fields_link(options)
    headers = ["Content-type": "application/json", Authorization: " Bearer #{token}"]

    case HTTPoison.put(url, body, headers) do
      {:ok, response = %{status_code: 200}} ->
        {:ok, response}

      {:ok, %{body: resp_body, status_code: status_code}} ->
        Logger.warn("Error #{status_code} when sending #{body} in form fields: #{resp_body}")
        {:error, body}

      {_, other} ->
        {:error, other}
    end
  end

  @spec form_fields_link(signup_options) :: {:ok, any} | {:error, any}
  def form_fields_link(%{tournament_id: tournament_id, user_id: user_id}) do
    "https://majestic.battlefy.com/tournaments/#{tournament_id}/user/#{user_id}/formFieldValues"
  end

  @spec accept_rules(signup_options) :: {:ok, any} | {:error, any}
  def accept_rules(options) do
    body = %{"name" => "CriticalRules", "value" => true} |> Poison.encode!()
    put_form_fields(options, body)
  end

  @spec connect_battlenet(signup_options) :: {:ok, any} | {:error, any}
  def connect_battlenet(options = %{battletag_full: battletag_full, battlenet_id: battlenet_id}) do
    body =
      %{
        "name" => "ConnectBattleNet",
        "value" => %{"battletag" => battletag_full, "accountID" => battlenet_id}
      }
      |> Poison.encode!()

    put_form_fields(options, body)
  end

  @spec masters_eligibility(signup_options) :: {:ok, any} | {:error, any}
  def masters_eligibility(options) do
    body = %{"name" => "HSMastersEligibility", "value" => true} |> Poison.encode!()
    put_form_fields(options, body)
  end

  @spec submit_discord(signup_options) :: {:ok, any} | {:error, any}
  def submit_discord(options = %{tournament_id: tournament_id, discord: discord}) do
    body =
      %{
        "name" => "CustomFields",
        "value" => [
          %{
            "name" => "Discord Name",
            "public" => false,
            "_id" => tournament_id,
            "value" => discord,
            "errorCode" => nil
          }
        ]
      }
      |> Poison.encode!()

    put_form_fields(options, body)
  end

  @spec submit_decks(signup_options) :: {:ok, any} | {:error, any}
  def submit_decks(options) do
    body =
      %{"name" => "SubmitConquestHSDecks", "value" => %{"deckStrings" => []}} |> Poison.encode!()

    put_form_fields(options, body)
  end

  @spec join_tournament(signup_options) :: {:ok, any} | {:error, any}
  def join_tournament(%{tournament_id: tournament_id, user_id: user_id, token: token}) do
    url = "https://majestic.battlefy.com/tournaments/#{tournament_id}/1v1-join/#{user_id}"
    body = %{"userID" => user_id} |> Poison.encode!()
    headers = ["Content-type": "application/json", Authorization: "Bearer #{token}"]

    case HTTPoison.post(url, body, headers) do
      {:ok, response = %{status_code: 200}} ->
        {:ok, response}

      {:ok, %{body: resp_body, status_code: status_code}} ->
        Logger.warn("Error #{status_code} when sending #{body} to #{url}: #{resp_body}")
        {:error, body}

      {_, other} ->
        {:error, other}
    end
  end

  @spec get_participants(String.t()) :: [Team.t()]
  def get_participants(tournament_id) do
    url = "https://dtmwra1jsgyb0.cloudfront.net/tournaments/#{tournament_id}/teams"

    get_body(url)
    |> Jason.decode!()
    |> Enum.map(&Team.from_raw_map/1)
  end
end
