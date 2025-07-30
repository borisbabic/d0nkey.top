defmodule Bot.SlashCommands.DeckCommand do
  @moduledoc false
  use Bot.SlashCommands.SlashCommand
  alias Hearthstone.DeckcodeExtractor

  @name "deck"
  @impl true
  def get_commands() do
    [
      %{
        name: @name,
        description: "View deck",
        options: [
          %{
            # string
            type: 3,
            name: "deckcode_or_link",
            description: "deckcode or link",
            required: true
          }
        ]
      }
    ]
  end

  @impl true
  def handle_interaction(%Interaction{data: %{name: @name}} = interaction) do
    deckcode_or_link = option_value(interaction, "deckcode_or_link")
    defer(interaction)

    message =
      with [deck] <- DeckcodeExtractor.extract_decks(deckcode_or_link),
           {:ok, deck} <- Backend.Hearthstone.create_or_get_deck(deck) do
        Bot.MessageHandler.create_deck_message(deck)
      else
        [_ | [_ | _]] -> "Too many decks found"
        _ -> "Could not parse deck"
      end

    follow_up(interaction, message)
    :ok
  end

  def handle_interaction(_), do: :skip
end
