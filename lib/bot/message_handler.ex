defmodule Bot.MessageHandler do
  @moduledoc """
  Handles incoming discord message
  """

  alias BackendWeb.Router.Helpers, as: Routes
  alias Nostrum.Api.Message
  alias Backend.Blizzard
  alias Nostrum.Struct.Embed
  alias Hearthstone.DeckcodeExtractor
  alias Backend.Hearthstone.Deck
  import Bot.MessageHandlerUtil
  require Logger

  @help_definitions %{
    "dhelp" => """
    ## dhelp (Help command)
    `!dhelp [command]`
    `!dhelp` - prints help for all commands (avoid using this),
    `!dhelp $command` ex `!dhelp !ldb` or `!dhelp ldb` - prints help for the specific command
    """,
    "blizz" => """
    ## `blizz` (Blizz o'clock)
    `!blizz`
    Returns when the next blizz o clock is occuring, using discord timestamps
    """,
    "ldb-top" => """
    ## `ldb-top` (Top players on leaderboards)
    `!ldb-top [$filters]

    Display the top 10 players on a leaderboard. See `!dhelp ldb` for filters

    examples:
    `!ldb-top l:BG 14`
    `!ldb-top l:BG r:US s:13`
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
    `!reveals format:embed`
    Get the next reveals, it has two formats `embed` and `text` (default).
    Checks the period from 1h ago to 24h ahead.
    Will look further in the future in order to show the minimum (3)
    """,
    "all-reveals" => """
    ## `all-reveals` (Card Reveals All)
    `!all-reveals `
    Like !reveals, but shows all the reveals, discord limits embeds so format:embed won't work.
    """,
    "bgreveals" => """
    ## `bgreveals` (Battlegrounds Reveals)
    `!bgreveals [$options]`
    `!bgreveals format:embed`
    Get the next BG reveals, it has two formats `embed` and `text` (default).
    Checks the period from 1h ago to 24h ahead.
    Will look further in the future in order to show the minimum (3)
    """,
    "all-bgreveals" => """
    ## `all-bgreveals` (All BG Reveals)
    `!all-bgreveals `
    Like !bgreveals, but shows all the BG reveals, discord limits embeds so format:embed won't work.
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
    "botd" => Bot.BattleOfTheDiscordsMessageHandler.help_message("botd"),
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
  def handle(%{author: %{bot: true}}), do: nil

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def handle(msg) do
    log_message(msg)

    case msg.content do
      "!ping" ->
        Message.create(msg.channel_id, "pong")

      <<"!create_highlight", _::binary>> ->
        handle_highlight(msg)

      <<"!c_h", _::binary>> ->
        handle_highlight(msg)

      <<"!ch", _::binary>> ->
        handle_highlight(msg)

      <<"!leaderboard", _::binary>> ->
        Bot.LdbMessageHandler.handle_top_leaderbaord(msg)

      <<"!ldb-top", _::binary>> ->
        Bot.LdbMessageHandler.handle_top_leaderbaord(msg)

      <<"!ldb_top", _::binary>> ->
        Bot.LdbMessageHandler.handle_top_leaderbaord(msg)

      <<"!ldb", _::binary>> ->
        Bot.LdbMessageHandler.handle_battletags_leaderboard(msg)

      <<"!bgreveals-all", _::binary>> ->
        Bot.RevealMessageHandler.handle_all_reveals(msg, :bgs)

      <<"!bgreveals", _::binary>> ->
        Bot.RevealMessageHandler.handle_reveals(msg, :bgs)

      <<"!all-bgreveals", _::binary>> ->
        Bot.RevealMessageHandler.handle_all_reveals(msg, :bgs)

      <<"!reveals-all", _::binary>> ->
        Bot.RevealMessageHandler.handle_all_reveals(msg)

      <<"!reveals", _::binary>> ->
        Bot.RevealMessageHandler.handle_reveals(msg)

      <<"!all-reveals", _::binary>> ->
        Bot.RevealMessageHandler.handle_all_reveals(msg)

      <<"!matchups_link", _::binary>> ->
        Bot.MatchupMessageHandler.handle_matchups_link(msg)

      <<"!matchup", _::binary>> ->
        Bot.MatchupMessageHandler.handle_matchup(msg)

      <<"!blizz", _::binary>> ->
        handle_blizz_o_clock(msg)

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
        Message.create(msg.channel_id, content)

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

      <<"!fenona", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("660d1af8ab0bd40c8c8a3fcc", msg)

      <<"!fenoeu", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("660d18c567e8040d50a099bd", msg)

      <<"!solary", _::binary>> ->
        Bot.BattlefyMessageHandler.handle_tournament_standings("66b63b2faedcd30040d11241", msg)

      <<"!bod", _::binary>> ->
        Bot.BattleOfTheDiscordsMessageHandler.handle(msg)

      <<"!botd", _::binary>> ->
        Bot.BattleOfTheDiscordsMessageHandler.handle(msg)

      <<"!thl", _::binary>> ->
        Bot.ThlMessageHandler.handle_thl(msg)

      <<"!dhelp", _::binary>> ->
        handle_help(msg)

      _ ->
        [
          handle_deck(msg),
          handle_timestamp(msg),
          handle_card(msg),
          handle_wiki(msg)
        ]
        |> Enum.find(:ignore, &(&1 != :ignore))
    end
  end

  def handle_blizz_o_clock(msg) do
    timestamp = Blizzard.next_blizz_o_clock() |> Timex.to_unix()

    reply(msg, "The next blizz o clock is <t:#{timestamp}:R>, ie <t:#{timestamp}:F>")
  end

  @spec log_message(Nostrum.Struct.Message.t()) :: any()
  defp log_message(msg) do
    Task.start(fn -> do_log_message(msg) end)
  end

  defp do_log_message(%{content: content, guild_id: guild_id}) do
    with command = "!" <> _ <-
           String.split(content, "\s") |> Enum.at(0) do
      write_log(command, guild_id)
    end
  end

  defp write_log(command, guild_id, level \\ :error) do
    memory = (:erlang.memory(:total) / :math.pow(1024, 2)) |> Float.round(2)

    Logger.log(
      level,
      "BOT MESSAGE ||| command: #{command} guild_id: #{guild_id} mem: #{memory} MiB"
    )
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

    Message.create(msg, content: reply_content)
  end

  def handle_card(msg) do
    case Regex.scan(~r/\[\[(.+?)\]\]/, msg.content, capture: :all_but_first) do
      matches = [_ | _] ->
        Task.start(fn ->
          write_log("card match #{Enum.join(matches, "|")}", msg.guild_id)
        end)

        galleries =
          matches
          |> Enum.map(&create_card_component/1)

        create_components_message(msg.channel_id, galleries)

      _ ->
        :ignore
    end
  end

  defp create_card_component([match]), do: create_card_component(match)

  defp create_card_component(match) do
    title =
      "### [#{match} (Other potential matches)](https://www.hsguru.com/cards?collectible=yes&order_by=name_similarity_#{URI.encode(match)})"

    card = Backend.Hearthstone.get_fuzzy_card(match)

    if card do
      Bot.CardMessageHandler.create_component(card, title_prepend: title)
    else
      %{
        type: 17,
        components: [
          %{
            type: 10,
            content: title
          }
        ]
      }
    end
  end

  def handle_timestamp(msg) do
    msg.content
    |> extract_timestamps()
    |> Enum.uniq_by(&"#{&1.timestamp}#{&1.format}")
    |> create_timestamp_reply(msg)
  end

  defp create_timestamp_reply([_ | _] = timestamps, msg) do
    message = Enum.map_join(timestamps, "\n\n", &timestamp_message_part/1)
    reply(msg, message)
  end

  defp create_timestamp_reply(_, _msg), do: :ignore

  defp timestamp_message_part(%{format: format, timestamp: timestamp, datetime_raw: datetime_raw}) do
    "> #{datetime_raw}\n<t:#{timestamp}#{format}>"
  end

  def extract_timestamps(content) do
    scanned =
      Regex.scan(
        ~r/<t:((?<datetime>\d{4}-\d{2}-\d{2}( |T)\d{2}(:\d{1,2})?(:\d{2})?)(?<format>:\w)?)>/,
        content,
        capture: :all_names
      )

    for [datetime_raw, format] <- scanned,
        {:ok, datetime} <- [Timex.parse(datetime_raw, "{ISO:Extended:Z}")],
        timestamp when is_integer(timestamp) <- [Timex.to_unix(datetime)] do
      %{
        format: format,
        timestamp: timestamp,
        datetime_raw: datetime_raw
      }
    end
  end

  def handle_wiki(msg) do
    msg.content
    |> extract_fandom_uris()
    |> use_new_wiki()
    |> create_wiki_reply(msg)
  end

  @spec extract_fandom_uris(String.t()) :: [Uri.t()]
  def extract_fandom_uris(content) do
    Regex.scan(~r/[^\s]+hearthstone.fandom.com[^\s]+/, content)
    |> Enum.map(fn [uri] -> URI.parse(uri) end)
    |> Enum.filter(fn
      %{host: "hearthstone.fandom.com"} -> true
      _ -> false
    end)
  end

  @spec use_new_wiki([Uri.t()]) :: Uri.t()
  defp use_new_wiki(fandom_uris) do
    Enum.map(fandom_uris, fn fandom ->
      Map.put(fandom, :host, "hearthstone.wiki.gg")
    end)
  end

  @spec create_wiki_reply([Uri.t()], Message.t()) :: {:ok, Message.t()}
  defp create_wiki_reply([], _msg), do: :ignore

  defp create_wiki_reply(uris, msg) do
    url_part = uris |> Enum.uniq() |> Enum.map_join("\n", &"<#{to_string(&1)}>")

    message = """
    The wiki has moved to hearthstone.wiki.gg:
    #{url_part}
    """

    reply(msg, message)
  end

  def handle_deck(msg) do
    with false <- msg.content =~ "##",
         {:ok, decks} <- extract_decks_from_msg(msg) do
      Task.start(fn ->
        write_log("deck command #{Enum.join(decks, ",")}", msg.guild_id)
      end)

      send_deck_messages(decks, msg)
    else
      {:error, {:too_many_decks, num_decks}} ->
        message =
          "Found too many decks (#{num_decks}). You must tag the bot to enable sending more than 1 deck"

        reply(msg, message)

      _ ->
        :ignore
    end
  end

  defp send_deck_messages(decks, msg) do
    for deckcode <- decks, {:ok, deck} <- [Deck.decode(deckcode)] do
      {missing_zilly?, new_deck} =
        if Deck.missing_zilliax_sideboard?(deck) do
          {true, Deck.brodeify(deck)}
        else
          {false, deck}
        end

      with {:ok, from_db} <- Backend.Hearthstone.create_or_get_deck(new_deck) do
        with {:ok, new_msg} <- reply(msg, content: create_deck_message(from_db)),
             true <- missing_zilly? do
          reply(new_msg,
            content:
              "I put Ben Brode in your deck instead of Zilliax 3000! HA HA HA!\n\nThe client won't accept the original deck because Zilliax is missing pieces, this way you can copy the code and import it into the client, replace Ben Brode and convert to standard!!!"
          )
        end
      end
    end
  end

  def extract_decks_from_msg(msg) do
    case {DeckcodeExtractor.performant_extract_from_text(msg.content), mentioned?(msg)} do
      {[], _} -> {:error, :no_decks}
      {[deck], _} -> {:ok, [deck]}
      {decks, false} -> {:error, {:too_many_decks, Enum.count(decks)}}
      {decks, true} -> {:ok, decks}
    end
  end

  @spec create_deck_message(String.t()) :: String.t()
  def create_deck_message(deck) do
    "```\n#{Backend.Hearthstone.DeckcodeEmbiggener.embiggen(deck)}\n```\nhttps://www.hsguru.com/deck/#{deck.id || Deck.deckcode(deck)}"
  end

  def handle_highlight(%{content: content, channel_id: channel_id}) do
    rest = get_options(content)
    url = Routes.leaderboard_url(BackendWeb.Endpoint, :index, %{highlight: rest})
    Message.create(channel_id, url)
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
