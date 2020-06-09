defmodule Backend.Infrastructure.BattlefyCommunicator do
  @moduledoc false
  require Logger
  alias Backend.Battlefy
  alias Backend.Blizzard
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchDeckstrings
  alias Backend.Battlefy.Profile
  alias Backend.Battlefy.Tournament
  import Backend.Battlefy.Communicator
  import Backend.Infrastructure.CommunicatorUtil
  @behaviour Backend.Battlefy.Communicator
  @type signup_options :: Communicator.signup_options()
  @type qualifier :: Communicator.qualifier()

  @doc """
  Get's the qualifiers that start between the start and end date (inclusive)
  """
  @spec get_masters_qualifiers(Date.t(), Date.t()) :: [qualifier]
  def get_masters_qualifiers(start_date = %Date{}, end_date = %Date{}) do
    with {:ok, end_time} <-
           NaiveDateTime.new(end_date.year, end_date.month, end_date.day, 23, 59, 59),
         {:ok, start_time} <-
           NaiveDateTime.new(start_date.year, start_date.month, start_date.day, 0, 0, 0) do
      get_masters_qualifiers(start_time, end_time)
    end
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
    Logger.info("Got masters qualifiers #{url} in #{div(u_secs, 1000)} ms")

    Poison.decode!(response.body)
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

    Logger.info(
      "Got invited players #{tour_stop && "for #{tour_stop} "}in #{div(u_secs, 1000)} ms"
    )

    Poison.decode!(response.body)
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

  @spec get_stage(Backend.Battlefy.stage_id()) :: Backend.Battlefy.Stagea.t()
  def get_stage(stage_id) do
    url = "https://api.battlefy.com/stages/#{stage_id}"

    get_body(url)
    |> Poison.decode!()
    |> Backend.Battlefy.Stage.from_raw_map()
  end

  @spec get_standings(Backend.Battlefy.stage_id()) :: [Backend.Battlefy.Standings.t()]
  def get_standings(stage_id) do
    url = "https://api.battlefy.com/stages/#{stage_id}/standings"

    get_body(url)
    |> Poison.decode!()
    |> Backend.Battlefy.Standings.from_raw_map_list()
  end

  @spec get_round_standings(Backend.Battlefy.stage_id(), integer | String.t()) :: [
          Backend.Battlefy.Standings.t()
        ]
  def get_round_standings(stage_id, round) do
    url = "https://api.battlefy.com/stages/#{stage_id}/rounds/#{round}/standings"

    get_body(url)
    |> Poison.decode!()
    |> Backend.Battlefy.Standings.from_raw_map_list()
  end

  @spec get_tournament(Backend.Battlefy.tournament_id()) :: Backend.Battlefy.Tournament.t()
  def get_tournament(tournament_id) do
    url =
      "https://dtmwra1jsgyb0.cloudfront.net/tournaments/#{tournament_id}?extend[stages]=true&extend[organization]=true"

    get_body(url)
    |> Poison.decode!()
    |> Enum.at(0)
    |> Backend.Battlefy.Tournament.from_raw_map()
  end

  @spec get_matches(Battlefy.stage_id(), Battlefy.get_matches_options()) :: [Match.t()]
  def get_matches(stage_id, opts \\ []) do
    url =
      case opts[:round] do
        nil -> "http://api.battlefy.com/stages/#{stage_id}/matches"
        round -> "http://api.battlefy.com/stages/#{stage_id}/matches?roundNumber=#{round}"
      end

    get_body(url)
    |> Poison.decode!()
    |> Enum.map(&Match.from_raw_map/1)
  end

  @spec get_match_deckstrings(Battlefy.tournament_id(), Battlefy.match_id()) :: [
          MatchDeckstrings.t()
        ]
  def get_match_deckstrings(tournament_id, match_id) do
    url =
      "https://majestic.battlefy.com/tournaments/#{tournament_id}/matches/#{match_id}/deckstrings"

    get_body(url)
    |> Poison.decode!()
    |> MatchDeckstrings.from_raw_map()
  end

  def get_profile(slug) do
    url = "https://api.battlefy.com/profile/#{slug}"

    get_body(url)
    |> Poison.decode!()
    |> Profile.from_raw_map()
  end

  @spec get_user_tournaments(String.t()) :: [Tournament.t()]
  def get_user_tournaments(slug) do
    # they return max 25 regardless of size. I don't feel like paginating or being smart about it
    url = "https://search.battlefy.com/user/#{slug}/tournaments?size=1000"

    raw =
      get_body(url)
      |> Poison.decode!()

    raw["tournaments"]
    |> Enum.map(&Tournament.from_raw_map/1)
  end

  @spec signup_for_qualifier(signup_options) :: {:ok, any} | {:error, any}
  def signup_for_qualifier(options) do
    with {:ok, _} <- accept_rules(options),
         {:ok, _} <- connect_battlenet(options),
         {:ok, _} <- masters_eligibility(options),
         {:ok, _} <- submit_discord(options),
         {:ok, _} <- submit_decks(options),
         {:ok, _} <- join_tournament(options) do
      Logger.info("Successfully signed up #{options.battletag_full} fo #{options.tournament_id}")
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
end
