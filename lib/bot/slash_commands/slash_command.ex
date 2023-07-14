defmodule Bot.SlashCommands.SlashCommand do
  @moduledoc "Helper for slash commands"
  alias Nostrum.Struct.Interaction
  @type interaction_response :: :ok | :halt | :skip | {:error, String.t() | :atom}
  @callback get_commands() :: [Map.t()]
  @callback handle_interaction(Interaction.t()) :: interaction_response()

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
      alias Nostrum.Struct.Interaction

      @spec create_response(String.t(), integer()) :: %{
              type: integer(),
              data: %{content: String.t()}
            }
      def create_response(message, type \\ 4) do
        %{
          type: type,
          data: %{
            content: message
          }
        }
      end

      @spec respond(Interaction.t(), String.t() | Map.t() | {String.t(), integer()}) ::
              {:ok} | Nostrum.Api.error()
      def respond(interaction, response_or_message) do
        response = response(response_or_message)
        Nostrum.Api.create_interaction_response(interaction, response)
      end

      defp response({msg, type}), do: create_response(msg, type)
      defp response(msg) when is_binary(msg), do: create_response(msg)
      defp response(rsp), do: rsp

      def follow_up(interaction, message) when is_binary(message) do
        Nostrum.Api.create_followup_message(interaction.token, %{content: message})
      end

      def ack(interaction), do: respond(interaction, %{type: 1})
      def defer(interaction), do: respond(interaction, %{type: 5})

      @spec option_value(Interaction.t(), String.t(), any()) :: any()
      def option_value(interaction, name, default \\ nil)

      def option_value(%{data: %{options: options}}, name, default),
        do: Enum.find_value(options, default, &(&1.name == name && &1.value))

      def option_value(_, _, default), do: default
    end
  end
end
