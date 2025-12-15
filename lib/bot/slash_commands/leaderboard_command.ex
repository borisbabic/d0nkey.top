defmodule Bot.SlashCommands.LeaderboardCommand do
  @moduledoc false
  use Bot.SlashCommands.SlashCommand
  alias Bot.LdbMessageHandler

  @names ["ldb", "leaderboard"]
  @count_names ["ldbc", "leaderboard_counts"]
  @impl true
  def get_commands() do
    leaderboard_commands =
      for name <- @names do
        %{
          name: name,
          description: "Check leaderboards",
          options: [
            %{
              # string
              type: 3,
              name: "battletags",
              description: "Space separated battletag(s)",
              required: true
            }
          ]
        }
      end

    count_commands =
      for name <- @count_names do
        %{
          name: name,
          description: "Get Leaderboards count",
          options: []
        }
      end

    leaderboard_commands ++ count_commands
  end

  @impl true
  def handle_interaction(%Interaction{data: %{name: name}} = interaction) when name in @names do
    {:ok, guild} = Nostrum.Api.Guild.get(interaction.guild_id)
    Nostrum.Struct.Guild.Member.guild_permissions(interaction.member, guild)
    command = "!ldb #{option_value(interaction, "battletags")}"
    defer(interaction)
    {base_criteria, battletags} = Bot.MessageHandlerUtil.get_criteria(command)
    criteria = [{"limit", 100} | base_criteria]
    entries = LdbMessageHandler.get_leaderboard_entries(battletags, criteria)

    response =
      case entries do
        [_ | _] ->
          tables = LdbMessageHandler.create_tables(entries)
          joined_tables = Enum.join(tables, "\n")
          "```\n#{joined_tables}\n```" |> text_response()

        _ ->
          travolta_response()
      end

    follow_up(interaction, response)
    :ok
  end

  def handle_interaction(%Interaction{data: %{name: name}} = interaction)
      when name in @count_names do
    defer(interaction)
    table = LdbMessageHandler.create_current_count_table()
    response = "```\n#{table}\n```" |> text_response()

    follow_up(interaction, response)
    :ok
  end

  def handle_interaction(_), do: :skip
end
