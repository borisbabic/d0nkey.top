defmodule Bot.MatchupMessageHandler do
  @moduledoc false
  alias BackendWeb.Router.Helpers, as: Routes
  alias Nostrum.Api
  alias Bot.MessageHandlerUtil, as: HandlerUtil
  alias Backend.HSReplay
  alias Backend.HSReplay.ArchetypeMatchups

  def handle_matchup(%{content: content, channel_id: channel_id}) do
    rest = HandlerUtil.get_options(content, :string)

    case get_vs_archetypes(rest) do
      {:error, reason} ->
        Api.create_message(channel_id, reason)

      {:ok, {[as | _], [vs | _]}} ->
        matchups = HSReplay.get_archetype_matchups()
        matchup = ArchetypeMatchups.get_matchup(matchups, as, vs)
        message = "#{as.name} has a #{matchup.win_rate}% winrate vs #{vs.name}"
        Api.create_message(channel_id, message)
    end
  end

  def handle_matchups_link(%{content: content, channel_id: channel_id}) do
    rest = HandlerUtil.get_options(content, :string)

    case get_vs_archetypes(rest) do
      {:error, reason} ->
        Api.create_message(channel_id, reason)

      {:ok, {as, vs}} ->
        as_ids = as |> Enum.map(fn a -> a.id end)
        vs_ids = vs |> Enum.map(fn a -> a.id end)
        as_names = as |> Enum.map(fn a -> a.name end)
        vs_names = vs |> Enum.map(fn a -> a.name end)
        url = Routes.hs_replay_url(BackendWeb.Endpoint, :matchups, %{as: as_ids, vs: vs_ids})

        Api.create_message(
          channel_id,
          "#{as_names |> Enum.join(", ")} vs #{vs_names |> Enum.join(", ")}: #{url}"
        )
    end
  end

  def get_vs_archetypes(rest) do
    split_archs =
      rest
      |> String.splitter(" vs ")
      |> Enum.to_list()

    [{as_found, as_missing}, {vs_found, vs_missing}] =
      split_archs
      |> Enum.map(fn a ->
        a
        |> String.splitter(",")
        |> HSReplay.find_archetypes_by_names()
      end)

    all_missing = as_missing ++ vs_missing

    if Enum.empty?(all_missing) do
      {:ok, {as_found, vs_found}}
    else
      missing_text =
        all_missing
        |> Enum.map(&String.trim/1)
        |> Enum.join(" nor for ")

      {:error, "Couldn't find a deck for #{missing_text}"}
    end
  end
end
