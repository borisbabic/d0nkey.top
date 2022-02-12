defmodule Bot.SlashCommandHandler do
  alias Bot.SlashCommands.SlashCommand
  alias Nostrum.Struct.Interaction

  def register_slash_commands() do
    commands()
    |> Enum.flat_map(& &1.get_commands())
    |> Enum.each(&register_command/1)
  end

  defp register_command(command) do
    case Application.get_env(:backend, :nostrum_slash_command_target) do
      :global ->
        Nostrum.Api.create_global_application_command(command)
      guild_id when is_integer(guild_id) ->
        Nostrum.Api.create_guild_application_command(guild_id, command)
      _ -> nil
    end
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [register_slash_commands: 0]

      def handle_event({:READY, _state, _ws_state}) do
        unquote(__MODULE__).register_slash_commands()
      end
      def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
        unquote(__MODULE__).handle_interaction(interaction)
      end
    end
  end
  @spec handle_interaction(Interaction.t()) :: SlashCommand.interaction_response()
  def handle_interaction(interaction) do
    do_handle_interaction(interaction, commands(), :ok)
  end
  @spec do_handle_interaction(Interaction.t(), [SlashCommand], SlashCommand.interaction_response()) :: SlashCommand.interaction_response()
  def do_handle_interaction(_interaction, _commands = [], _), do: :ok
  def do_handle_interaction(_interaction, _commands, :halt), do: :halted
  def do_handle_interaction(_interaction, _commands, error = {:error, _}), do: error
  def do_handle_interaction(interaction, [curr|rest], _) do
    result = apply(curr, :handle_interaction, [interaction])
    do_handle_interaction(interaction, rest, result)
  end

  def commands() do
    Application.get_env(:backend, :nostrum_slash_commands, [])
  end
end
