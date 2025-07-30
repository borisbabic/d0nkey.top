defmodule Bot.SlashCommands.GuildBattletagManagementCommand do
  @moduledoc false
  use Bot.SlashCommands.SlashCommand
  alias Backend.DiscordBot

  @add_battletags "add_battletags"
  @remove_battletags "remove_battletags"
  @reset_battletags "reset_battletags"
  @change_channel "change_battletags_channel"
  @list_battletags "list_battletags"
  @impl true
  def get_commands() do
    [
      %{
        name: @add_battletags,
        description: "Add battletags to server",
        default_member_permissions: Nostrum.Permission.to_bitset([:manage_guild]),
        options: [
          %{
            # string
            type: 3,
            name: "battletags",
            description: "Space separated battletags to add",
            required: true
          }
        ]
      },
      %{
        name: @remove_battletags,
        description: "Remove battletags to server",
        default_member_permissions: Nostrum.Permission.to_bitset([:manage_guild]),
        options: [
          %{
            # string
            type: 3,
            name: "battletags",
            description: "Space separated battletags to remove",
            required: true
          }
        ]
      },
      %{
        name: @reset_battletags,
        description: "Reset battletags - this deletes all saved battletags",
        default_member_permissions: Nostrum.Permission.to_bitset([:manage_guild])
      },
      %{
        name: @list_battletags,
        description: "List saved battletags",
        default_member_permissions: Nostrum.Permission.to_bitset([:manage_guild])
      },
      %{
        name: @change_channel,
        description: "Change channel used to source battletags",
        default_member_permissions: Nostrum.Permission.to_bitset([:manage_guild]),
        options: [
          %{
            type: 7,
            name: "channel",
            description: "The channel to source battletags from",
            required: true
          },
          %{
            type: 5,
            name: "reset_battletags",
            description: "Also reset battletags (ie delete all)",
            default: false
          }
        ]
      }
    ]
  end

  @impl true
  def handle_interaction(%Interaction{data: %{name: @add_battletags}} = interaction) do
    battletags = option_value(interaction, "battletags") |> String.split(" ")

    case DiscordBot.add_battletags(interaction.guild_id, battletags) do
      {:ok, _} ->
        respond(interaction, "Battletags successfully adding", [:ephemeral])

      {:error, error} ->
        respond(interaction, "Error adding battletags: #{error}", [:ephemeral])
    end

    :ok
  end

  def handle_interaction(%Interaction{data: %{name: @remove_battletags}} = interaction) do
    battletags = option_value(interaction, "battletags") |> String.split(" ")

    case DiscordBot.remove_battletags(interaction.guild_id, battletags) do
      {:ok, _} ->
        respond(interaction, "Battletags successfully removing", [:ephemeral])

      {:error, error} ->
        respond(interaction, "Error removing battletags: #{error}", [:ephemeral])
    end

    :ok
  end

  def handle_interaction(%Interaction{data: %{name: @list_battletags}} = interaction) do
    battletags = DiscordBot.get_battletags(interaction.guild_id)
    base_message = Enum.sort(battletags) |> Enum.join(" ")

    message =
      case DiscordBot.get_guild_config(interaction.guild_id) do
        {:ok, %{channel_id: channel_id}} when is_integer(channel_id) ->
          """
          Battletags channel: <##{channel_id}>
          #{base_message}
          """

        _ ->
          base_message
      end

    respond(interaction, message, [:ephemeral])
    :ok
  end

  def handle_interaction(%Interaction{data: %{name: @reset_battletags}} = interaction) do
    case DiscordBot.reset_battletags(interaction.guild_id) do
      {:ok, _} ->
        respond(interaction, "Battletags successfully reset", [:ephemeral])

      {:error, error} ->
        respond(interaction, "Error resetting battletags: #{error}", [:ephemeral])
    end

    :ok
  end

  def handle_interaction(%Interaction{data: %{name: @change_channel}} = interaction) do
    channel = option_value(interaction, "channel")
    reset_battletags = option_value(interaction, "reset_battletags")

    with {:ok, _} <- DiscordBot.change_channel(interaction.guild_id, channel),
         {:ok, _} <- reset_battletag(interaction.guild_id, !!reset_battletags) do
      respond(interaction, "Channel successfully changed", [:ephemeral])
    end

    :ok
  end

  defp reset_battletag(guild_id, reset_battletags \\ true)

  defp reset_battletag(guild_id, false) do
    {:ok, :resetting_not_requested}
  end

  defp reset_battletag(guild_id, true) do
    DiscordBot.reset_battletags(guild_id)
  end

  def handle_interaction(_), do: :skip
end
