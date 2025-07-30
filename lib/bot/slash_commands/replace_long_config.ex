defmodule Bot.SlashCommands.ReplaceLongConfigCommand do
  @moduledoc false
  use Bot.SlashCommands.SlashCommand

  @enable "enable_replace_long"
  @disable "disable_replace_long"
  @impl true
  def get_commands() do
    [
      %{
        name: @enable,
        description: "Enable replacing long deckcodes",
        default_member_permissions: Nostrum.Permission.to_bitset([:manage_guild])
      },
      %{
        name: @disable,
        description: "Enable replacing long deckcodes",
        default_member_permissions: Nostrum.Permission.to_bitset([:manage_guild])
      }
    ]
  end

  @impl true
  def handle_interaction(%Interaction{data: %{name: @enable}} = interaction) do
    Backend.DiscordBot.enable_replace_long(interaction.guild_id)
    respond(interaction, "Long deckcodes will now be replaced", [:ephemeral])
    :ok
  end

  def handle_interaction(%Interaction{data: %{name: @disable}} = interaction) do
    Backend.DiscordBot.disable_replace_long(interaction.guild_id)
    respond(interaction, "Long deckcodes will no longer be replaced", [:ephemeral])
    :ok
  end

  def handle_interaction(_), do: :skip
end
