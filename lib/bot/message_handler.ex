defmodule Bot.MessageHandler do
  @moduledoc """
  Handles incoming discord message
  """

  alias BackendWeb.Router.Helpers, as: Routes
  alias Nostrum.Api
  alias Backend.Blizzard
  alias Backend.Leaderboards
  alias Nostrum.Struct.Embed
  import Bot.MessageHandlerUtil

  @help_definitions %{
    "dhelp" => """
    ## dhelp (Help command)
    `!dhelp [command]`
    `!dhelp` - prints help for all commands (avoid using this),
    `!dhelp $command` ex `!dhelp !ldb` or `!dhelp ldb` - prints help for the specific command
    """,
    "ldb" => """
    ## `ldb` (Leaderboards command)
    `!ldb [$battletags] [$filters]`

    Display current leaderboards either for supplied battletags or for server battletags (see below) with available filters (see below)
    `!ldb` # uses server battletags (see `!dhelp server battletags` for info), currently doesn't show all ranks by defaults, max 5000
    `!ldb D0nkey SomeOtherBtag` Searches for D0nkey and SomeOtherBtag, shows all ranks by default

    ### Filters
    filter syntax is `filter:value`, example `leaderboard_id:BG`
    some filters have shorthands like `ldb` instead of `leaderboard_id`
    available filters with shorthands are:

    - `s`, `ssn`, `season_id`
    - `l`, `ldb`, `ldb_id`, `leaderboard_id`
    - `r`, `rgn`, `region`
    - `min_rank`
    - `max_rank`
    - `min_rating`
    - `max_rating`

    example:
    `!ldb D0nkey SomeOtherBtag ldb:BG region:EU` Searches for D0nkey and SomeOtherBtag on EU BG leaderboards
    """,
    "ping" => """
    ## ping
    pong
    """,
    "reveals" => """
    ## `reveals` (Card Reveals)
    `!reveals [$options]`
    `!reveals format:text`
    Get the next reveals, it has two formats `embed` (default) and `text`.
    Checks the period from 1h ago to 24h ahead.
    Will look further in the future in order to show the minimum (3)
    """,
    "all-reveals" => """
    ## `all-reveals` (Card Reveals All)
    `!reveals format:text`
    Like !reveals, but shows all the reveals, but requires format:text since discord limits embeds
    """,
    "cards" => """
    ## `cards` (Latest HS Cards)
    `!cards [$filters]`
    Replies with latest hs cards, can be filtered (see below). Not all cards in the past are ordered correctly
    ## Filters
    filter syntax is `filter:value`, example `class:warrior`
    some filters have alt forms

    ### Filters
    - `limit` - how many cards to return default: `3`, max: `10`
    - `collectible` - ex: `collectible:no`, default: `yes`
    - `format` - `standard` or `wild`, currently no support for twist/new age
    - `order_by` - default: `latest`, also possible: `name_similarity_$search_without_spaces`
    - `mana_cost` - exact cost, comparisons are planned
    - `health` - exact health, comparisons are planned
    - `attack` - exact attack, comparisons are planned
    - `set`, `sets`, `card_set`, `card_sets`  - can specify multiple using | as a separator
    - `type`, `types`, `card_type`, `card_types` - can specify multiple using | as a separator
    - `class`, `classes` - can specify multiple using | as a separator
    - `keywords`, `keyword` - can specify multiple using | as a separator
    - `rarity`, `rarities` - can specify multiple using | as a separator
    - `school`, `schools`, `spell_school`, `spell_schools` - can specify multiple using | as a separator
    - `minion_type` - can specify multiple using | as a separator
    """,
    "card-stats" => """
    ## `card-stats`
    `!card-stats [$filters]`
    Replies with a summary of card stats for the supplied filters.
    Shares the same possible filters with `!cards`, see `!dhelp cards` for a list of possible Filters
    default filters: `collectible:yes format:standard`
    """,
    "patchnotes" => """
    ## `patchnotes` (Hearthstone Patchnotes)
    `!patchnotes`
    Responds with a link to the latest patchnotes
    Note: only tagged patch notes on the site are included
    Hotfix forum post patch notes aren't considered
    """,
    "battlefy" => """
    ## `battletfy` (Battlefy Standings)
    `!battlefy $tournament_id`
    Shows the standings for a battelfy tournament for server battletags (see `!dhelp server battletags`) 
    Some notable third party tournaments get shorthands like `!bunnyopen`
    """,
    "thl" => """
    ## `thl` (Team Hearth LEAGUE)
    `!thl [name:]$discord_tags`
    Makes it easier to link to THL servers discord users.
    Intedend for use to make it easier for teammates to contact opponents.
    Only usable by people in the thl server.
    example:
    `!thl d0nkey`
    `!thl my_title:d0nkey`
    `!thl my_title:d0nkey thispersondoesnotexist somebodyelsenonexistent OldTag#1234`
    """,
    "mt" => """
    ## `mt` (Masters Tour)
    `!mt [$mt]`
    Shows standings for a masters tour for server battletags (see `!dhelp server battletags`) 
    If no mt is supplied it will default to the current mt, if there is one
    """,
    "mtq" => """
    ## `mtq` (Masters Tour Qualifiers)
    RIP
    """,
    "server battletags" => """
    ### Server Battletags
    Server battletags are sourced from a channel in the server that starts with #battletags
    Battletags are saved on the server for speed reasons
    Only new messages in that channel are evaluated, ie message edits or deletions are ignored
    """
  }
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def handle(msg) do
    case msg.content do
      "!ping" ->
        Api.create_message(msg.channel_id, "pong")

      <<"!create_highlight", _::binary>> ->
        handle_highlight(msg)

      <<"!c_h", _::binary>> ->
        handle_highlight(msg)

      <<"!ch", _::binary>> ->
        handle_highlight(msg)

      <<"!leaderboard", _::binary>> ->
        handle_leaderboard(msg)

      <<"!ldb", _::binary>> ->
        Bot.LdbMessageHandler.handle_battletags_leaderboard(msg)

      <<"!reveals", _::binary>> ->
        Bot.RevealMessageHandler.handle_reveals(msg)

      <<"!all-reveals", _::binary>> ->
        Bot.RevealMessageHandler.handle_all_reveals(msg)

      <<"!matchups_link", _::binary>> ->
        Bot.MatchupMessageHandler.handle_matchups_link(msg)

      <<"!matchup", _::binary>> ->
        Bot.MatchupMessageHandler.handle_matchup(msg)

      <<"!battlefy", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings(msg)

      <<"!cards", _::binary>> ->
        Bot.CardMessageHandler.handle_cards(msg)

      <<"!card-stats", _::binary>> ->
        Bot.CardMessageHandler.handle_card_stats(msg)

      <<"!mtq", _::binary>> ->
        Bot.MTMessageHandler.handle_qualifier_standings(msg)

      <<"!mt", _::binary>> ->
        Bot.MTMessageHandler.handle_mt_standings(msg)

      <<"!patchnotes", _::binary>> ->
        content = Backend.LatestHSArticles.patch_notes_url()
        Api.create_message(msg.channel_id, content)

      <<"!orangeopen", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("625e7176b31e652df4f63a63", msg)

      <<"!oo", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("625e7176b31e652df4f63a63", msg)

      <<"!maxopen8", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("62017079b5a9a57b56cc25b8", msg)

      <<"!maxopen", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("6319a0dec4fa012b14cd0f4b", msg)

      <<"!maxopen9", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("6319a0dec4fa012b14cd0f4b", msg)

      <<"!bunnyopen", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("636ec2c1a2fbe70578c33023", msg)

      <<"!tch", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("6271bd62d44c844993e4e1a7", msg)

      <<"!thl", _::binary>> ->
        Bot.ThlMessageHandler.handle_thl(msg)

      <<"!dhelp", _::binary>> ->
        handle_help(msg)

      <<"[[", _::binary>> ->
        handle_card(msg)

      _ ->
        [
          handle_deck(msg),
          handle_card(msg)
        ]
        |> Enum.find(:ignore, &(&1 != :ignore))
    end
  end

  def get_help(target) do
    case Map.get(@help_definitions, target) do
      command_specific when is_binary(command_specific) -> command_specific
      _ -> general_help_reply()
    end
  end

  def general_help_reply() do
    command_specific =
      for {key, _} <- @help_definitions, !(key =~ " ") do
        "`\t!dhelp #{key}`"
      end
      |> Enum.join("\n")

    "Check individual command helps: \n#{command_specific}"
  end

  def handle_help(msg) do
    reply_content =
      msg
      |> get_options(:string)
      |> String.trim()
      |> String.trim("!")
      |> get_help()

    Api.create_message(msg, content: reply_content)
  end

  def handle_card(msg) do
    case Regex.scan(~r/\[\[(.+?)\]\]/, msg.content, capture: :all_but_first) do
      matches = [_ | _] ->
        embeds =
          matches
          |> Enum.map(&create_card_embed/1)
          |> Enum.filter(& &1)

        Api.create_message(msg.channel_id, embeds: embeds)

      _ ->
        :ignore
    end
  end

  defp create_card_embed([match]), do: create_card_embed(match)

  defp create_card_embed(match) do
    embed =
      %Embed{}
      |> Embed.put_author(
        match,
        "https://www.hsguru.com/cards?collectible=yes&order_by=name_similarity_#{URI.encode(match)}",
        nil
      )

    case Backend.Hearthstone.cards([
           {"order_by", "name_similarity_#{match}"},
           {"limit", 1},
           {"collectible", "yes"}
         ]) do
      [card | _] -> Bot.CardMessageHandler.create_card_embed(card, embed: embed)
      _ -> embed
    end
  end

  def handle_deck(msg) do
    with {:ok, deck} <- Backend.Hearthstone.Deck.decode(msg.content),
         false <- msg.content =~ "#",
         {:ok, message} <- create_deck_message(deck) do
      Api.create_message(msg.channel_id, message)
    else
      _ -> :ignore
    end
  end

  def create_deck_message(deck) do
    with {:ok, from_db} <- Backend.Hearthstone.create_or_get_deck(deck) do
      {:ok,
       "```\n#{Backend.Hearthstone.DeckcodeEmbiggener.embiggen(from_db)}\n```\nhttps://www.hsguru.com/deck/#{from_db.id}"}
    end
  end

  def handle_highlight(%{content: content, channel_id: channel_id}) do
    rest = get_options(content)
    url = Routes.leaderboard_url(BackendWeb.Endpoint, :index, %{highlight: rest})
    Api.create_message(channel_id, url)
  end

  def handle_leaderboard(%{content: content, channel_id: channel_id}) do
    rest = get_options(content)

    ldb_params =
      %{season_id: season_id, leaderboard_id: leaderboard_id, region: region} =
      parse_leaderboard_options(rest)

    {leaderboard_entries, _} = Leaderboards.get_leaderboard(region, leaderboard_id, season_id)

    query_params =
      ldb_params
      |> Enum.map(fn {k, v} -> {Recase.to_camel(to_string(k)), v} end)

    url = Routes.leaderboard_url(BackendWeb.Endpoint, :index, query_params)

    table =
      leaderboard_entries
      |> Enum.take(10)
      |> Enum.map_join(
        "\n",
        fn le ->
          "#{String.pad_trailing(to_string(le.position), 3, [" "])} #{le.battletag}"
        end
      )

    message = "#{url}\n```#{table}\n```"
    Api.create_message(channel_id, message)
  end

  @doc """
  Extracts the season_id, leaderboard_id and region from the options passed to !leaderboard

  ## Example
  iex> Bot.MessageHandler.parse_leaderboard_options([" 100", "AP", "BG"])
  %{season_id: 100, leaderboard_id: :BG, region: AP}
  iex> Bot.MessageHandler.parse_leaderboard_options(" 69 adfsf ql5q THIS IS AWESOME BG"])
  %{season_id: 69, leaderboard_id: :BG, region: EU}
  """
  @spec parse_leaderboard_options([String.t()] | String.t()) :: %{
          leaderboard_id: Blizzard.leaderboard(),
          region: Blizzard.leaderboard(),
          season_id: integer()
        }
  def parse_leaderboard_options(options) do
    normalized =
      if is_binary(options) do
        String.splitter(options, " ")
      else
        options
      end

    parsed =
      normalized
      |> Stream.map(&String.upcase/1)
      |> Enum.reduce(
        %{},
        fn opt, acc ->
          case {Blizzard.to_region(opt), Blizzard.to_leaderboard(opt), Integer.parse(opt)} do
            {{:ok, region}, _, _} -> Map.put_new(acc, :region, region)
            {_, {:ok, leaderboard_id}, _} -> Map.put_new(acc, :leaderboard_id, leaderboard_id)
            {_, _, {season_id, _}} -> Map.put_new(acc, :season_id, season_id)
            _ -> acc
          end
        end
      )

    default = %{
      season_id: Blizzard.get_season_id(Date.utc_today(), :STD),
      leaderboard_id: :STD,
      region: :EU
    }

    Map.merge(default, parsed)
  end

  # guild: D0nkey, channel: #botspam_private
  def test_message(
        content,
        channel_id \\ 669_190_514_591_006_731,
        guild_id \\ 666_596_230_100_549_652
      ) do
    %Nostrum.Struct.Message{
      content: content,
      channel_id: channel_id,
      guild_id: guild_id
    }
    |> handle()
  end
end
