defmodule Bot.SlashCommands.MTQCommand do
  use Bot.SlashCommands.SlashCommand


  @impl true
  def get_commands() do
    [
      %{
        name: "mtq",
        description: "Get mtq results for members of this guild/server",
        options: [
          %{
            type: 4,
            name: "num",
            description: "Check only this MTQ",
            min_value: 1,
            required: false
          }
        ]
      }
    ]
  end

  @impl true
  def handle_interaction(%{date: %{name: n}}) when n not in ["mtq"], do: :skip
  def handle_interaction(interaction = %Interaction{data: %{name: "mtq"}, guild_id: guild_id}) do
    num = option_value(interaction, "num")
    defer(interaction)
    message =
      case Bot.MTMessageHandler.standings_message(guild_id, num) do
        "" -> "Nobody played Sadge"
        msg -> msg
      end
    follow_up(interaction, message)
    :ok
  end
end
