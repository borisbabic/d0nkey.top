defmodule Bot.SlashCommands.CardCommand do
  @moduledoc false
  use Bot.SlashCommands.SlashCommand

  @name "card"
  @impl true
  def get_commands() do
    [
      %{
        name: @name,
        description: "Get card info",
        options: [
          %{
            # string
            type: 3,
            name: "card_search",
            description: "Card search",
            min_value: 1,
            required: true
          }
        ]
      }
    ]
  end

  @impl true
  def handle_interaction(%Interaction{data: %{name: @name}} = interaction) do
    card_search = option_value(interaction, "card_search")
    defer(interaction)
    component = Bot.MessageHandler.create_card_component(card_search)

    components_follow_up(interaction, component)
    :ok
  end

  def handle_interaction(_), do: :skip
end
