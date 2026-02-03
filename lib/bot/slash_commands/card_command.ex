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
    embeds = Bot.CardMessageHandler.create_card_info_embed(card_search, true)

    embeds_follow_up(interaction, embeds)
    :ok
  end

  def handle_interaction(_), do: :skip
end
