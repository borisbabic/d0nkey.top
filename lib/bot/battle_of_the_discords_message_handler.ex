defmodule Bot.BattleOfTheDiscordsMessageHandler do
  @moduledoc "Handles !botd messages for battle of the discords"
  import Bot.MessageHandlerUtil
  alias Backend.Battlefy

  @participating_discords [
    %{id: 405_445_346_236_563_476, slug: "tdf"},
    %{id: 158_099_275_136_499_713, slug: "cc"},
    %{id: 147_167_584_666_517_505, slug: "vs"},
    %{id: 734_477_782_456_991_934, slug: "mbuu"},
    %{id: 534_455_756_129_435_649, slug: "thl"}
  ]

  @battlefy_id "65e37d5f1f2be50c38d43332"
  @custom_field "653e9d91e73f05464d894a50"

  # Some random mt
  # @battlefy_id "5efbcdaca2b8f022508f65c3"
  # @custom_field "5ec5ca7153702b1ab2a5c9dc"

  def battlefy_id(), do: @battlefy_id

  def help_message(command \\ "botd") do
    """
    ## #{command} Battle of the Discords
    `!#{command} [$discord_abbreviation]`
    `!#{command} total`
    `!#{command}`

    Available abbreviations: #{Enum.map_join(slugs(), " ", &"`#{&1}`")}

    Will return standings for the botd tournament depending on the argument
    - `!#{command} total` -> overall record per discord
    - `!#{command} $discord_abbreviation`, ex `!#{command} cc` will show standings for people who registered as that discord on battlefy
    - `!#{command}` is a shorthand, for the above in participating discords, or for `!battlefy #{@battlefy_id}` in others

    """
  end

  def handle(msg) do
    msg
    |> get_options()
    |> handle(msg)
  end

  def handle([], msg) do
    Enum.find(@participating_discords, fn %{id: id} -> id == msg.guild_id end)
    |> case do
      %{slug: slug} ->
        handle([slug], msg)

      _ ->
        Bot.BattlefyMessageHandler.handle_tournament_standings(@battlefy_id, msg)
    end
  end

  def handle([t], msg) when t in ["total", "totals"] do
    sorted_standings()
    |> Battlefy.merge_standings_by_custom_field(@custom_field, value_mapper: &String.upcase/1)
    |> Battlefy.filter_and_sort_standings()
    |> Bot.BattlefyMessageHandler.create_message()
    |> send_message(msg)
  end

  def handle([slug], msg) when slug in ["tdf", "cc", "vs", "thl", "mbuu"] do
    sorted_standings()
    |> Enum.filter(fn s ->
      slug ==
        s
        |> Battlefy.custom_field_value(@custom_field, "miss")
        |> String.downcase()
    end)
    |> Bot.BattlefyMessageHandler.create_message()
    |> send_message(msg)
  end

  def handle(_, msg),
    do: send_message("Invalid argument, see `!dhelp botd` ", msg)

  defp slugs(), do: for(%{slug: slug} <- @participating_discords, do: slug)

  def sorted_standings(),
    do: Battlefy.get_standings(@battlefy_id) |> Battlefy.filter_and_sort_standings()

  @spec participating_guild?(Nostrum.Struct.Message.t() | integer()) :: boolean
  def participating_guild?(%{guild_id: guild_id}), do: participating_guild?(guild_id)

  def participating_guild?(guild_id),
    do: Enum.any?(@participating_discords, fn %{id: id} -> id == guild_id end)
end
